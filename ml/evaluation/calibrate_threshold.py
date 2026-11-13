"""Validation-only confidence calibration and uncertainty threshold selection."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader

from ml.training.constants import CANONICAL_CLASSES, INPUT_IMAGE_SIZE
from ml.training.dataset import RecyclingSplitDataset
from ml.training.models import build_classifier
from ml.training.transforms import build_eval_transform

DEFAULT_SPLITS_CSV = Path(__file__).resolve().parent.parent / "datasets" / "splits.csv"
DEFAULT_CHECKPOINT = Path(__file__).resolve().parent.parent / "artifacts" / "best_checkpoint.pt"
DEFAULT_METADATA = Path(__file__).resolve().parent.parent / "artifacts" / "model_metadata.json"
DEFAULT_CALIBRATION_REPORT = (
    Path(__file__).resolve().parent / "reports" / "calibration_report.json"
)


def compute_ece(confidences: np.ndarray, correct: np.ndarray, n_bins: int = 10) -> float:
    """Compute Expected Calibration Error across uniform probability bins."""
    bin_edges = np.linspace(0.0, 1.0, n_bins + 1)
    ece = 0.0
    total = max(1, len(confidences))
    for i in range(n_bins):
        lo, hi = bin_edges[i], bin_edges[i + 1]
        mask = (confidences >= lo) & (confidences <= hi if i == n_bins - 1 else confidences < hi)
        if not np.any(mask):
            continue
        bin_acc = float(correct[mask].mean())
        bin_conf = float(confidences[mask].mean())
        ece += (float(mask.sum()) / total) * abs(bin_acc - bin_conf)
    return round(ece, 4)


def calibrate_thresholds(
    splits_csv: Path = DEFAULT_SPLITS_CSV,
    checkpoint_path: Path = DEFAULT_CHECKPOINT,
    metadata_path: Path = DEFAULT_METADATA,
    report_path: Path = DEFAULT_CALIBRATION_REPORT,
    target_identified_precision: float = 0.90,
) -> dict:
    """Evaluate validation probabilities and pick identified/low_confidence thresholds."""
    ckpt = torch.load(checkpoint_path, map_location="cpu", weights_only=True)
    classes = tuple(ckpt["classes"])
    if classes != CANONICAL_CLASSES:
        raise ValueError(f"Unexpected classes in checkpoint: {classes}")

    image_size = int(ckpt.get("image_size", INPUT_IMAGE_SIZE))
    model = build_classifier(
        architecture=str(ckpt["architecture"]),
        num_classes=len(classes),
        pretrained=False,
    )
    model.load_state_dict(ckpt["state_dict"])
    model.eval()

    val_ds = RecyclingSplitDataset(
        splits_csv=splits_csv,
        split="val",
        transform=build_eval_transform(image_size),
    )
    val_loader = DataLoader(val_ds, batch_size=32, shuffle=False)

    all_probs: list[np.ndarray] = []
    all_targets: list[int] = []
    with torch.inference_mode():
        for images, targets, _paths in val_loader:
            logits = model(images)
            probs = torch.softmax(logits, dim=1).numpy()
            all_probs.append(probs)
            all_targets.extend(targets.tolist())

    probs_arr = np.concatenate(all_probs, axis=0)
    targets_arr = np.array(all_targets)
    preds_arr = probs_arr.argmax(axis=1)
    confs_arr = probs_arr.max(axis=1)
    correct_arr = (preds_arr == targets_arr).astype(np.float32)

    sweep: list[dict] = []
    chosen_identified = 0.70
    best_coverage_meeting_target = -1.0

    for thresh in (0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85):
        accepted = confs_arr >= thresh
        coverage = float(accepted.mean())
        precision = float(correct_arr[accepted].mean()) if np.any(accepted) else 0.0
        sweep.append(
            {
                "threshold": thresh,
                "coverage": round(coverage, 4),
                "accuracy_above_threshold": round(precision, 4),
                "accepted_count": int(accepted.sum()),
            }
        )
        if precision >= target_identified_precision and coverage > best_coverage_meeting_target:
            best_coverage_meeting_target = coverage
            chosen_identified = thresh

    # If no threshold achieved target precision, pick 0.75 conservatively.
    if best_coverage_meeting_target < 0.0:
        chosen_identified = 0.75
    low_conf_threshold = round(max(0.35, chosen_identified - 0.25), 2)

    ece = compute_ece(confs_arr, correct_arr)
    calibration_report = {
        "split_used": "val",
        "val_samples": int(len(targets_arr)),
        "val_accuracy_unthresholded": round(float(correct_arr.mean()), 4),
        "expected_calibration_error_ece": ece,
        "target_identified_precision": target_identified_precision,
        "selected_identified_threshold": chosen_identified,
        "selected_low_confidence_threshold": low_conf_threshold,
        "threshold_sweep": sweep,
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(calibration_report, indent=2), encoding="utf-8")

    if metadata_path.is_file():
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        metadata["identified_threshold"] = chosen_identified
        metadata["low_confidence_threshold"] = low_conf_threshold
        metadata["validation_ece"] = ece
        metadata_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")

    return calibration_report


def main() -> None:
    parser = argparse.ArgumentParser(description="Calibrate confidence thresholds on val split.")
    parser.add_argument("--splits-csv", type=Path, default=DEFAULT_SPLITS_CSV)
    parser.add_argument("--checkpoint", type=Path, default=DEFAULT_CHECKPOINT)
    parser.add_argument("--metadata", type=Path, default=DEFAULT_METADATA)
    parser.add_argument("--report", type=Path, default=DEFAULT_CALIBRATION_REPORT)
    parser.add_argument("--target-precision", type=float, default=0.90)
    args = parser.parse_args()
    result = calibrate_thresholds(
        splits_csv=args.splits_csv,
        checkpoint_path=args.checkpoint,
        metadata_path=args.metadata,
        report_path=args.report,
        target_identified_precision=args.target_precision,
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
