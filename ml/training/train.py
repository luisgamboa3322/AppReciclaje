"""Reproducible transfer learning trainer for PECOX Vision waste classifiers."""

from __future__ import annotations

import argparse
import json
import random
import time
from datetime import UTC, datetime
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn
from sklearn.metrics import f1_score
from torch.utils.data import DataLoader

from ml.training.constants import (
    CANONICAL_CLASSES,
    DEFAULT_IDENTIFIED_THRESHOLD,
    DEFAULT_LOW_CONFIDENCE_THRESHOLD,
    INPUT_IMAGE_SIZE,
)
from ml.training.dataset import RecyclingSplitDataset
from ml.training.models import SUPPORTED_ARCHITECTURES, build_classifier
from ml.training.transforms import build_eval_transform, build_train_transform

DEFAULT_SPLITS_CSV = Path(__file__).resolve().parent.parent / "datasets" / "splits.csv"
DEFAULT_OUTPUT_DIR = Path(__file__).resolve().parent.parent / "artifacts"
DEFAULT_HISTORY_PATH = (
    Path(__file__).resolve().parent.parent / "evaluation" / "reports" / "training_history.json"
)


def set_deterministic_seed(seed: int) -> None:
    """Fix Python, NumPy, and PyTorch random seeds."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)


def _set_backbone_trainable(model: nn.Module, architecture: str, trainable: bool) -> None:
    head_prefix = "fc." if architecture == "resnet18" else "classifier."
    for name, param in model.named_parameters():
        if name.startswith(head_prefix):
            param.requires_grad = True
        else:
            param.requires_grad = trainable


def _run_epoch(
    model: nn.Module,
    loader: DataLoader,
    criterion: nn.Module,
    device: torch.device,
    optimizer: torch.optim.Optimizer | None = None,
) -> tuple[float, float, float]:
    is_train = optimizer is not None
    model.train(is_train)

    total_loss = 0.0
    total_samples = 0
    all_targets: list[int] = []
    all_preds: list[int] = []

    context = torch.enable_grad() if is_train else torch.inference_mode()
    with context:
        for images, targets, _paths in loader:
            images = images.to(device)
            targets = targets.to(device)

            if is_train:
                optimizer.zero_grad()

            logits = model(images)
            loss = criterion(logits, targets)

            if is_train:
                loss.backward()
                optimizer.step()

            batch_size = targets.size(0)
            total_loss += float(loss.item()) * batch_size
            total_samples += batch_size

            preds = logits.argmax(dim=1).cpu().tolist()
            all_preds.extend(preds)
            all_targets.extend(targets.cpu().tolist())

    avg_loss = total_loss / max(1, total_samples)
    accuracy = sum(int(p == t) for p, t in zip(all_preds, all_targets, strict=True)) / max(
        1, total_samples
    )
    macro_f1 = float(f1_score(all_targets, all_preds, average="macro", zero_division=0))
    return avg_loss, accuracy, macro_f1


def train_model(
    splits_csv: Path = DEFAULT_SPLITS_CSV,
    output_dir: Path = DEFAULT_OUTPUT_DIR,
    history_path: Path = DEFAULT_HISTORY_PATH,
    architecture: str = "resnet18",
    version: str = "resnet18-trashnet-v1.0.0",
    epochs: int = 8,
    freeze_epochs: int = 2,
    batch_size: int = 32,
    lr_head: float = 1e-3,
    lr_backbone: float = 1e-4,
    weight_decay: float = 1e-4,
    image_size: int = INPUT_IMAGE_SIZE,
    seed: int = 42,
    num_workers: int = 0,
) -> dict:
    """Train and save the best checkpoint selected strictly by validation macro-F1."""
    if architecture not in SUPPORTED_ARCHITECTURES:
        raise ValueError(f"Unsupported architecture '{architecture}'")

    set_deterministic_seed(seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    train_ds = RecyclingSplitDataset(
        splits_csv=splits_csv,
        split="train",
        transform=build_train_transform(image_size),
    )
    val_ds = RecyclingSplitDataset(
        splits_csv=splits_csv,
        split="val",
        transform=build_eval_transform(image_size),
    )

    train_loader = DataLoader(
        train_ds,
        batch_size=batch_size,
        shuffle=True,
        num_workers=num_workers,
    )
    val_loader = DataLoader(
        val_ds,
        batch_size=batch_size,
        shuffle=False,
        num_workers=num_workers,
    )

    # Mild inverse-frequency weights capped cleanly so rare classes ('other') are not ignored.
    counts = np.array(train_ds.class_counts(), dtype=np.float32)
    raw_weights = counts.sum() / (len(CANONICAL_CLASSES) * np.maximum(counts, 1.0))
    class_weights = torch.tensor(np.clip(raw_weights, 0.5, 3.0), dtype=torch.float32, device=device)
    criterion = nn.CrossEntropyLoss(weight=class_weights, label_smoothing=0.05)

    model = build_classifier(architecture=architecture, pretrained=True).to(device)

    output_dir.mkdir(parents=True, exist_ok=True)
    checkpoint_path = output_dir / "best_checkpoint.pt"
    metadata_path = output_dir / "model_metadata.json"

    best_val_f1 = -1.0
    best_epoch = 0
    history: list[dict] = []
    optimizer: torch.optim.Optimizer | None = None
    scheduler: torch.optim.lr_scheduler.CosineAnnealingLR | None = None

    started_at = time.perf_counter()
    for epoch in range(1, epochs + 1):
        in_warmup = epoch <= freeze_epochs
        if epoch == 1 and freeze_epochs > 0:
            _set_backbone_trainable(model, architecture, trainable=False)
            optimizer = torch.optim.AdamW(
                [p for p in model.parameters() if p.requires_grad],
                lr=lr_head,
                weight_decay=weight_decay,
            )
            scheduler = None
        elif epoch == freeze_epochs + 1 or (freeze_epochs == 0 and epoch == 1):
            _set_backbone_trainable(model, architecture, trainable=True)
            head_prefix = "fc." if architecture == "resnet18" else "classifier."
            head_params = [p for n, p in model.named_parameters() if n.startswith(head_prefix)]
            backbone_params = [
                p for n, p in model.named_parameters() if not n.startswith(head_prefix)
            ]
            optimizer = torch.optim.AdamW(
                [
                    {"params": backbone_params, "lr": lr_backbone},
                    {"params": head_params, "lr": lr_head * 0.5},
                ],
                weight_decay=weight_decay,
            )
            scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
                optimizer,
                T_max=max(1, epochs - freeze_epochs),
            )

        assert optimizer is not None
        epoch_start = time.perf_counter()
        train_loss, train_acc, train_f1 = _run_epoch(
            model, train_loader, criterion, device, optimizer=optimizer
        )
        val_loss, val_acc, val_f1 = _run_epoch(model, val_loader, criterion, device, optimizer=None)
        if scheduler is not None and not in_warmup:
            scheduler.step()

        elapsed_sec = round(time.perf_counter() - epoch_start, 2)
        row = {
            "epoch": epoch,
            "phase": "head_warmup" if in_warmup else "fine_tune",
            "train_loss": round(train_loss, 4),
            "train_accuracy": round(train_acc, 4),
            "train_macro_f1": round(train_f1, 4),
            "val_loss": round(val_loss, 4),
            "val_accuracy": round(val_acc, 4),
            "val_macro_f1": round(val_f1, 4),
            "elapsed_sec": elapsed_sec,
        }
        history.append(row)
        print(
            f"[Epoch {epoch}/{epochs} | {row['phase']}] "
            f"train_f1={row['train_macro_f1']:.4f} val_acc={row['val_accuracy']:.4f} "
            f"val_f1={row['val_macro_f1']:.4f} ({elapsed_sec}s)"
        )

        if val_f1 > best_val_f1:
            best_val_f1 = val_f1
            best_epoch = epoch
            torch.save(
                {
                    "version": version,
                    "architecture": architecture,
                    "classes": list(CANONICAL_CLASSES),
                    "image_size": image_size,
                    "state_dict": model.state_dict(),
                    "best_epoch": epoch,
                    "val_macro_f1": round(val_f1, 4),
                    "val_accuracy": round(val_acc, 4),
                    "seed": seed,
                },
                checkpoint_path,
            )

    total_sec = round(time.perf_counter() - started_at, 2)
    metadata = {
        "version": version,
        "architecture": architecture,
        "classes": list(CANONICAL_CLASSES),
        "image_size": image_size,
        "device_trained_on": str(device),
        "seed": seed,
        "epochs": epochs,
        "freeze_epochs": freeze_epochs,
        "batch_size": batch_size,
        "best_epoch": best_epoch,
        "best_val_macro_f1": round(best_val_f1, 4),
        "identified_threshold": DEFAULT_IDENTIFIED_THRESHOLD,
        "low_confidence_threshold": DEFAULT_LOW_CONFIDENCE_THRESHOLD,
        "checkpoint_filename": checkpoint_path.name,
        "trained_at_utc": datetime.now(UTC).isoformat(),
        "total_train_seconds": total_sec,
    }
    metadata_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")

    history_payload = {"metadata": metadata, "epochs": history}
    history_path.parent.mkdir(parents=True, exist_ok=True)
    history_path.write_text(json.dumps(history_payload, indent=2), encoding="utf-8")
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser(description="Train PECOX Vision classifier.")
    parser.add_argument("--splits-csv", type=Path, default=DEFAULT_SPLITS_CSV)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--history-path", type=Path, default=DEFAULT_HISTORY_PATH)
    parser.add_argument(
        "--architecture", choices=list(SUPPORTED_ARCHITECTURES), default="resnet18"
    )
    parser.add_argument("--version", type=str, default="resnet18-trashnet-v1.0.0")
    parser.add_argument("--epochs", type=int, default=8)
    parser.add_argument("--freeze-epochs", type=int, default=2)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--lr-head", type=float, default=1e-3)
    parser.add_argument("--lr-backbone", type=float, default=1e-4)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    meta = train_model(
        splits_csv=args.splits_csv,
        output_dir=args.output_dir,
        history_path=args.history_path,
        architecture=args.architecture,
        version=args.version,
        epochs=args.epochs,
        freeze_epochs=args.freeze_epochs,
        batch_size=args.batch_size,
        lr_head=args.lr_head,
        lr_backbone=args.lr_backbone,
        seed=args.seed,
    )
    print(json.dumps(meta, indent=2))


if __name__ == "__main__":
    main()
