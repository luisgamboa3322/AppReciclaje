"""Held-out test evaluation, confusion matrix plot, error analysis, and latency benchmark."""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import matplotlib
import numpy as np
import torch
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from torch.utils.data import DataLoader

from ml.training.constants import (
    CANONICAL_CLASSES,
    DEFAULT_IDENTIFIED_THRESHOLD,
    DEFAULT_LOW_CONFIDENCE_THRESHOLD,
    INPUT_IMAGE_SIZE,
)
from ml.training.dataset import RecyclingSplitDataset
from ml.training.models import build_classifier
from ml.training.transforms import build_eval_transform

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

DEFAULT_SPLITS_CSV = Path(__file__).resolve().parent.parent / "datasets" / "splits.csv"
DEFAULT_CHECKPOINT = Path(__file__).resolve().parent.parent / "artifacts" / "best_checkpoint.pt"
DEFAULT_METADATA = Path(__file__).resolve().parent.parent / "artifacts" / "model_metadata.json"
DEFAULT_REPORTS_DIR = Path(__file__).resolve().parent / "reports"


def _save_confusion_matrix_plot(
    cm: np.ndarray,
    classes: tuple[str, ...],
    output_path: Path,
    title: str,
) -> None:
    fig, ax = plt.subplots(figsize=(7.5, 6.2), dpi=160)
    im = ax.imshow(cm, interpolation="nearest", cmap="Greens")
    ax.figure.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    ticks = np.arange(len(classes))
    ax.set(
        xticks=ticks,
        yticks=ticks,
        xticklabels=classes,
        yticklabels=classes,
        ylabel="Etiqueta real",
        xlabel="Predicción del modelo",
        title=title,
    )
    plt.setp(ax.get_xticklabels(), rotation=30, ha="right", rotation_mode="anchor")

    thresh = cm.max() / 2.0 if cm.size else 0.0
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(
                j,
                i,
                format(int(cm[i, j]), "d"),
                ha="center",
                va="center",
                color="white" if cm[i, j] > thresh else "#17221E",
                fontsize=10,
                fontweight="bold",
            )

    fig.tight_layout()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path)
    plt.close(fig)


def evaluate_test_split(
    splits_csv: Path = DEFAULT_SPLITS_CSV,
    checkpoint_path: Path = DEFAULT_CHECKPOINT,
    metadata_path: Path = DEFAULT_METADATA,
    reports_dir: Path = DEFAULT_REPORTS_DIR,
    latency_samples: int = 50,
) -> dict:
    """Evaluate trained model once on the held-out test set and emit honest reports."""
    ckpt = torch.load(checkpoint_path, map_location="cpu", weights_only=True)
    classes = tuple(ckpt["classes"])
    if classes != CANONICAL_CLASSES:
        raise ValueError(f"Canonical class order mismatch: {classes} != {CANONICAL_CLASSES}")

    metadata: dict = {}
    if metadata_path.is_file():
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))

    identified_thresh = float(
        metadata.get("identified_threshold", DEFAULT_IDENTIFIED_THRESHOLD)
    )
    low_conf_thresh = float(
        metadata.get("low_confidence_threshold", DEFAULT_LOW_CONFIDENCE_THRESHOLD)
    )
    image_size = int(ckpt.get("image_size", INPUT_IMAGE_SIZE))

    model = build_classifier(
        architecture=str(ckpt["architecture"]),
        num_classes=len(classes),
        pretrained=False,
    )
    model.load_state_dict(ckpt["state_dict"])
    model.eval()

    test_ds = RecyclingSplitDataset(
        splits_csv=splits_csv,
        split="test",
        transform=build_eval_transform(image_size),
    )
    test_loader = DataLoader(test_ds, batch_size=32, shuffle=False)

    all_probs: list[np.ndarray] = []
    all_targets: list[int] = []
    all_paths: list[str] = []

    with torch.inference_mode():
        for images, targets, paths in test_loader:
            logits = model(images)
            probs = torch.softmax(logits, dim=1).numpy()
            all_probs.append(probs)
            all_targets.extend(targets.tolist())
            all_paths.extend(list(paths))

    probs_arr = np.concatenate(all_probs, axis=0)
    targets_arr = np.array(all_targets)
    preds_arr = probs_arr.argmax(axis=1)
    confs_arr = probs_arr.max(axis=1)

    acc = float(accuracy_score(targets_arr, preds_arr))
    macro_p, macro_r, macro_f1, _ = precision_recall_fscore_support(
        targets_arr,
        preds_arr,
        average="macro",
        zero_division=0,
    )
    per_class_report = classification_report(
        targets_arr,
        preds_arr,
        labels=list(range(len(classes))),
        target_names=list(classes),
        output_dict=True,
        zero_division=0,
    )
    cm = confusion_matrix(targets_arr, preds_arr, labels=list(range(len(classes))))

    # Thresholded test behavior
    is_identified = confs_arr >= identified_thresh
    is_low_conf = (confs_arr < identified_thresh) & (confs_arr >= low_conf_thresh)
    is_unknown = confs_arr < low_conf_thresh

    identified_acc = (
        float((preds_arr[is_identified] == targets_arr[is_identified]).mean())
        if np.any(is_identified)
        else 0.0
    )

    # Single-sample CPU latency measurement
    bench_count = min(latency_samples, len(test_ds))
    with torch.inference_mode():
        warmup_tensor, _, _ = test_ds[0]
        _ = model(warmup_tensor.unsqueeze(0))
        latencies_ms: list[float] = []
        for idx in range(bench_count):
            tensor, _, _ = test_ds[idx]
            inp = tensor.unsqueeze(0)
            t0 = time.perf_counter()
            _ = model(inp)
            latencies_ms.append((time.perf_counter() - t0) * 1000.0)

    # Worst over-confident mistakes for honest qualitative analysis
    misclassified_indices = np.where(preds_arr != targets_arr)[0]
    sorted_errors = sorted(
        misclassified_indices.tolist(),
        key=lambda i: float(confs_arr[i]),
        reverse=True,
    )
    error_examples = [
        {
            "file": Path(all_paths[i]).name,
            "true_label": classes[int(targets_arr[i])],
            "predicted_label": classes[int(preds_arr[i])],
            "confidence": round(float(confs_arr[i]), 4),
        }
        for i in sorted_errors[:15]
    ]

    metrics_payload = {
        "model_version": ckpt["version"],
        "architecture": ckpt["architecture"],
        "split": "test",
        "test_samples": int(len(targets_arr)),
        "accuracy": round(acc, 4),
        "macro_precision": round(float(macro_p), 4),
        "macro_recall": round(float(macro_r), 4),
        "macro_f1": round(float(macro_f1), 4),
        "per_class": {
            cls_name: {
                "precision": round(float(per_class_report[cls_name]["precision"]), 4),
                "recall": round(float(per_class_report[cls_name]["recall"]), 4),
                "f1_score": round(float(per_class_report[cls_name]["f1-score"]), 4),
                "support": int(per_class_report[cls_name]["support"]),
            }
            for cls_name in classes
        },
        "confusion_matrix_labels": list(classes),
        "confusion_matrix": cm.tolist(),
        "uncertainty_gating": {
            "identified_threshold": identified_thresh,
            "low_confidence_threshold": low_conf_thresh,
            "identified_count": int(is_identified.sum()),
            "identified_coverage": round(float(is_identified.mean()), 4),
            "identified_accuracy": round(identified_acc, 4),
            "low_confidence_count": int(is_low_conf.sum()),
            "unknown_count": int(is_unknown.sum()),
        },
        "cpu_latency_ms": {
            "samples_measured": bench_count,
            "mean": round(float(np.mean(latencies_ms)), 2),
            "p50": round(float(np.percentile(latencies_ms, 50)), 2),
            "p95": round(float(np.percentile(latencies_ms, 95)), 2),
        },
    }

    reports_dir.mkdir(parents=True, exist_ok=True)
    (reports_dir / "metrics.json").write_text(
        json.dumps(metrics_payload, indent=2), encoding="utf-8"
    )
    (reports_dir / "error_analysis.json").write_text(
        json.dumps(
            {
                "total_test_errors": int(len(misclassified_indices)),
                "top_confident_misclassifications": error_examples,
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    _save_confusion_matrix_plot(
        cm=cm,
        classes=classes,
        output_path=reports_dir / "confusion_matrix.png",
        title=f"PECOX Vision — Matriz de Confusión Test ({ckpt['version']})",
    )
    return metrics_payload


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate PECOX classifier on held-out test set.")
    parser.add_argument("--splits-csv", type=Path, default=DEFAULT_SPLITS_CSV)
    parser.add_argument("--checkpoint", type=Path, default=DEFAULT_CHECKPOINT)
    parser.add_argument("--metadata", type=Path, default=DEFAULT_METADATA)
    parser.add_argument("--reports-dir", type=Path, default=DEFAULT_REPORTS_DIR)
    parser.add_argument("--latency-samples", type=int, default=50)
    args = parser.parse_args()

    result = evaluate_test_split(
        splits_csv=args.splits_csv,
        checkpoint_path=args.checkpoint,
        metadata_path=args.metadata,
        reports_dir=args.reports_dir,
        latency_samples=args.latency_samples,
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
