"""Tests for camera_robust transforms, real-world split ingestion, TTA, and feedback export."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

import pytest
import torch
from PIL import Image

from ml.datasets.export_feedback_report import export_feedback_report
from ml.datasets.prepare_splits import build_splits_and_eda
from ml.inference.predictor import WasteClassifierPredictor
from ml.tests.test_splits_and_classes import _write_textured_png
from ml.training.constants import CANONICAL_CLASSES, INPUT_IMAGE_SIZE
from ml.training.models import build_classifier
from ml.training.transforms import build_train_transform


@pytest.mark.parametrize("profile", ["baseline", "camera_robust"])
def test_train_transform_profiles_output_shape(profile: str) -> None:
    transform = build_train_transform(INPUT_IMAGE_SIZE, profile=profile)  # type: ignore[arg-type]
    image = Image.new("RGB", (512, 384), color=(110, 150, 180))
    tensor = transform(image)
    assert tensor.shape == (3, INPUT_IMAGE_SIZE, INPUT_IMAGE_SIZE)
    assert torch.isfinite(tensor).all()


def test_unknown_transform_profile_raises() -> None:
    with pytest.raises(ValueError, match="Unsupported augmentation profile"):
        build_train_transform(INPUT_IMAGE_SIZE, profile="unknown_profile")  # type: ignore[arg-type]


def test_real_world_dir_ingestion_in_splits(tmp_path: Path) -> None:
    raw_root = tmp_path / "dataset-resized"
    real_world_root = tmp_path / "real_world"
    base_colors = {
        "plastic": (40, 140, 220),
        "glass": (80, 190, 130),
        "metal": (160, 165, 175),
        "cardboard": (175, 130, 80),
        "paper": (235, 232, 220),
        "trash": (105, 85, 95),
    }

    seed_counter = 100
    for raw_cls, rgb in base_colors.items():
        cls_dir = raw_root / raw_cls
        cls_dir.mkdir(parents=True)
        for sample_i in range(6):
            _write_textured_png(cls_dir / f"{raw_cls}_{sample_i}.jpg", seed_counter, rgb)
            seed_counter += 1

    # Add 4 real-world plastic + other samples using canonical PECOX folder names.
    (real_world_root / "plastic").mkdir(parents=True)
    (real_world_root / "other").mkdir(parents=True)
    for idx in range(2):
        _write_textured_png(
            real_world_root / "plastic" / f"phone_p_{idx}.jpg",
            seed_counter,
            (55, 155, 230),
        )
        seed_counter += 1
        _write_textured_png(
            real_world_root / "other" / f"phone_o_{idx}.jpg",
            seed_counter,
            (125, 95, 110),
        )
        seed_counter += 1

    report = build_splits_and_eda(
        raw_root=raw_root,
        splits_csv=tmp_path / "splits.csv",
        eda_report_path=tmp_path / "eda.json",
        seed=42,
        real_world_root=real_world_root,
    )

    assert report["real_world_images"] == 4
    assert report["raw_valid_images"] == 40
    assert report["leakage_checks"]["sha256_cross_split_overlap"] == 0
    assert report["leakage_checks"]["dhash_cross_split_overlap"] == 0


def test_export_feedback_report_from_sqlite(tmp_path: Path) -> None:
    db_path = tmp_path / "pecox_test.db"
    conn = sqlite3.connect(db_path)
    try:
        conn.execute(
            """
            CREATE TABLE classifications (
                id TEXT PRIMARY KEY,
                predicted_material TEXT NOT NULL,
                confirmed_material TEXT NOT NULL,
                confidence REAL,
                model_version TEXT NOT NULL
            )
            """
        )
        conn.executemany(
            "INSERT INTO classifications VALUES (?, ?, ?, ?, ?)",
            [
                ("1", "paper", "plastic", 0.4051, "resnet18-trashnet-v1.0.0"),
                ("2", "plastic", "plastic", 0.3655, "resnet18-trashnet-v1.0.0"),
                ("3", "glass", "glass", 0.9120, "resnet18-trashnet-v1.0.0"),
            ],
        )
        conn.commit()
    finally:
        conn.close()

    output_path = tmp_path / "feedback_report.json"
    real_world_dir = tmp_path / "real_world"
    (real_world_dir / "plastic").mkdir(parents=True)

    report = export_feedback_report(
        sqlite_path=db_path,
        output_path=output_path,
        real_world_dir=real_world_dir,
    )

    assert output_path.is_file()
    loaded = json.loads(output_path.read_text(encoding="utf-8"))
    assert loaded["total_confirmed_classifications"] == 3
    assert loaded["exact_model_matches"] == 2
    assert loaded["user_corrections_total"] == 1
    assert loaded["top_confusion_pairs"] == {"paper -> plastic": 1}
    assert loaded["class_curation_priority"][0]["pecox_label"] == "plastic"
    assert report["observed_agreement_rate"] == round(2 / 3, 4)


def test_predictor_tta_returns_valid_result(tmp_path: Path) -> None:
    model = build_classifier(
        architecture="resnet18",
        num_classes=len(CANONICAL_CLASSES),
        pretrained=False,
    )
    ckpt_path = tmp_path / "best_checkpoint.pt"
    torch.save(
        {
            "version": "resnet18-test",
            "architecture": "resnet18",
            "classes": list(CANONICAL_CLASSES),
            "image_size": INPUT_IMAGE_SIZE,
            "state_dict": model.state_dict(),
        },
        ckpt_path,
    )
    meta_path = tmp_path / "model_metadata.json"
    meta_path.write_text(
        json.dumps(
            {
                "identified_threshold": 0.50,
                "low_confidence_threshold": 0.35,
            }
        ),
        encoding="utf-8",
    )

    predictor = WasteClassifierPredictor(
        checkpoint_path=ckpt_path,
        metadata_path=meta_path,
        use_tta=True,
    )
    img = Image.new("RGB", (320, 240), color=(40, 160, 210))
    res_tta = predictor.predict_pil(img)
    res_single = predictor.predict_pil(img, use_tta=False)

    assert res_tta.material in CANONICAL_CLASSES
    assert res_single.material in CANONICAL_CLASSES
    assert 0.0 <= res_tta.confidence <= 1.0
    assert 0.0 <= res_single.confidence <= 1.0
