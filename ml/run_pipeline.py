"""End-to-end reproducible pipeline runner: download -> split -> train -> calibrate -> evaluate."""

from __future__ import annotations

import argparse
from pathlib import Path

from ml.datasets.download_trashnet import DEFAULT_RAW_DIR, download_and_extract
from ml.datasets.prepare_splits import (
    DEFAULT_EDA_REPORT,
    DEFAULT_SPLITS_CSV,
    build_splits_and_eda,
)
from ml.evaluation.calibrate_threshold import calibrate_thresholds
from ml.evaluation.evaluate import DEFAULT_REPORTS_DIR, evaluate_test_split
from ml.training.models import SUPPORTED_ARCHITECTURES
from ml.training.train import DEFAULT_OUTPUT_DIR, train_model


def main() -> None:
    parser = argparse.ArgumentParser(description="Run full PECOX Vision ML baseline pipeline.")
    parser.add_argument(
        "--architecture", choices=list(SUPPORTED_ARCHITECTURES), default="resnet18"
    )
    parser.add_argument("--version", type=str, default="resnet18-trashnet-v1.0.0")
    parser.add_argument("--epochs", type=int, default=6)
    parser.add_argument("--freeze-epochs", type=int, default=2)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--skip-download", action="store_true")
    args = parser.parse_args()

    if not args.skip_download:
        extracted_root = download_and_extract(raw_dir=DEFAULT_RAW_DIR)
    else:
        extracted_root = DEFAULT_RAW_DIR / "dataset-resized"

    build_splits_and_eda(
        raw_root=extracted_root,
        splits_csv=DEFAULT_SPLITS_CSV,
        eda_report_path=DEFAULT_EDA_REPORT,
        seed=args.seed,
    )

    artifacts_dir = Path(DEFAULT_OUTPUT_DIR)
    history_path = Path(DEFAULT_REPORTS_DIR) / "training_history.json"
    train_model(
        splits_csv=DEFAULT_SPLITS_CSV,
        output_dir=artifacts_dir,
        history_path=history_path,
        architecture=args.architecture,
        version=args.version,
        epochs=args.epochs,
        freeze_epochs=args.freeze_epochs,
        batch_size=args.batch_size,
        seed=args.seed,
    )

    checkpoint_path = artifacts_dir / "best_checkpoint.pt"
    metadata_path = artifacts_dir / "model_metadata.json"

    calibrate_thresholds(
        splits_csv=DEFAULT_SPLITS_CSV,
        checkpoint_path=checkpoint_path,
        metadata_path=metadata_path,
    )

    evaluate_test_split(
        splits_csv=DEFAULT_SPLITS_CSV,
        checkpoint_path=checkpoint_path,
        metadata_path=metadata_path,
        reports_dir=Path(DEFAULT_REPORTS_DIR),
    )


if __name__ == "__main__":
    main()
