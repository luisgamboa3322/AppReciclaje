"""End-to-end reproducible pipeline runner: download -> split -> train -> calibrate -> evaluate."""

from __future__ import annotations

import argparse
from pathlib import Path

from ml.datasets.download_trashnet import DEFAULT_RAW_DIR, download_and_extract
from ml.datasets.prepare_splits import (
    DEFAULT_EDA_REPORT,
    DEFAULT_REAL_WORLD_DIR,
    DEFAULT_SPLITS_CSV,
    build_splits_and_eda,
)
from ml.evaluation.calibrate_threshold import calibrate_thresholds
from ml.evaluation.evaluate import DEFAULT_REPORTS_DIR, evaluate_test_split
from ml.training.models import SUPPORTED_ARCHITECTURES
from ml.training.train import DEFAULT_OUTPUT_DIR, train_model
from ml.training.transforms import SUPPORTED_PROFILES


def main() -> None:
    parser = argparse.ArgumentParser(description="Run full PECOX Vision ML pipeline.")
    parser.add_argument(
        "--architecture", choices=list(SUPPORTED_ARCHITECTURES), default="resnet18"
    )
    parser.add_argument("--profile", choices=list(SUPPORTED_PROFILES), default="baseline")
    parser.add_argument("--version", type=str, default="resnet18-trashnet-v1.0.0")
    parser.add_argument("--epochs", type=int, default=6)
    parser.add_argument("--freeze-epochs", type=int, default=2)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--lr-head", type=float, default=1e-3)
    parser.add_argument("--lr-backbone", type=float, default=1e-4)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--skip-download", action="store_true")
    parser.add_argument("--skip-splits", action="store_true")
    parser.add_argument("--real-world-dir", type=Path, default=DEFAULT_REAL_WORLD_DIR)
    parser.add_argument("--splits-csv", type=Path, default=DEFAULT_SPLITS_CSV)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--reports-dir", type=Path, default=DEFAULT_REPORTS_DIR)
    parser.add_argument("--init-checkpoint", type=Path, default=None)
    args = parser.parse_args()

    if not args.skip_splits:
        if not args.skip_download:
            extracted_root = download_and_extract(raw_dir=DEFAULT_RAW_DIR)
        else:
            extracted_root = DEFAULT_RAW_DIR / "dataset-resized"

        eda_report_path = Path(args.reports_dir) / DEFAULT_EDA_REPORT.name
        build_splits_and_eda(
            raw_root=extracted_root,
            splits_csv=args.splits_csv,
            eda_report_path=eda_report_path,
            seed=args.seed,
            real_world_root=args.real_world_dir,
        )

    artifacts_dir = Path(args.output_dir)
    reports_dir = Path(args.reports_dir)
    history_path = reports_dir / "training_history.json"
    train_model(
        splits_csv=args.splits_csv,
        output_dir=artifacts_dir,
        history_path=history_path,
        architecture=args.architecture,
        version=args.version,
        epochs=args.epochs,
        freeze_epochs=args.freeze_epochs,
        batch_size=args.batch_size,
        lr_head=args.lr_head,
        lr_backbone=args.lr_backbone,
        seed=args.seed,
        profile=args.profile,
        init_checkpoint=args.init_checkpoint,
    )

    checkpoint_path = artifacts_dir / "best_checkpoint.pt"
    metadata_path = artifacts_dir / "model_metadata.json"

    calibrate_thresholds(
        splits_csv=args.splits_csv,
        checkpoint_path=checkpoint_path,
        metadata_path=metadata_path,
    )

    evaluate_test_split(
        splits_csv=args.splits_csv,
        checkpoint_path=checkpoint_path,
        metadata_path=metadata_path,
        reports_dir=reports_dir,
    )


if __name__ == "__main__":
    main()
