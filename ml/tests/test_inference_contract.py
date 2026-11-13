"""Contract tests for checkpoint export, loading, thresholding, and image validation."""

from __future__ import annotations

import io
import json
from pathlib import Path

import pytest
import torch
from PIL import Image

from ml.inference.predictor import (
    ArtifactContractError,
    InvalidImageError,
    WasteClassifierPredictor,
)
from ml.training.constants import CANONICAL_CLASSES
from ml.training.models import build_classifier


def _save_dummy_checkpoint(
    tmp_path: Path,
    classes: tuple[str, ...] = CANONICAL_CLASSES,
    identified_threshold: float = 0.70,
    low_confidence_threshold: float = 0.45,
) -> Path:
    model = build_classifier(architecture="resnet18", num_classes=len(classes), pretrained=False)
    ckpt_path = tmp_path / "best_checkpoint.pt"
    torch.save(
        {
            "version": "resnet18-test-v0.0.1",
            "architecture": "resnet18",
            "classes": list(classes),
            "image_size": 224,
            "state_dict": model.state_dict(),
        },
        ckpt_path,
    )
    meta_path = tmp_path / "model_metadata.json"
    meta_path.write_text(
        json.dumps(
            {
                "version": "resnet18-test-v0.0.1",
                "identified_threshold": identified_threshold,
                "low_confidence_threshold": low_confidence_threshold,
            }
        ),
        encoding="utf-8",
    )
    return ckpt_path


def _make_jpeg_bytes(mode: str = "RGB") -> bytes:
    buf = io.BytesIO()
    img = Image.new(mode, (320, 240), color=128 if mode == "L" else (30, 180, 120))
    if mode == "RGBA":
        img.save(buf, format="PNG")
    else:
        img.save(buf, format="JPEG")
    return buf.getvalue()


def test_predictor_loads_and_returns_valid_contract(tmp_path: Path) -> None:
    ckpt_path = _save_dummy_checkpoint(tmp_path)
    predictor = WasteClassifierPredictor(checkpoint_path=ckpt_path)

    result = predictor.predict_bytes(_make_jpeg_bytes("RGB"))
    assert result.model_version == "resnet18-test-v0.0.1"
    assert result.architecture == "resnet18"
    assert result.material in CANONICAL_CLASSES
    assert 0.0 <= result.confidence <= 1.0
    assert result.status in {"identified", "low_confidence", "unknown"}
    assert result.inference_ms >= 0.0

    # Also verifies PNG RGBA conversion works smoothly
    rgba_result = predictor.predict_bytes(_make_jpeg_bytes("RGBA"))
    assert rgba_result.material in CANONICAL_CLASSES


def test_predictor_unknown_status_forces_other_when_below_low_threshold(tmp_path: Path) -> None:
    # A threshold of 0.999 forces a random-weight 6-class model below low_confidence_threshold
    ckpt_path = _save_dummy_checkpoint(
        tmp_path,
        identified_threshold=0.9999,
        low_confidence_threshold=0.999,
    )
    predictor = WasteClassifierPredictor(checkpoint_path=ckpt_path)

    result = predictor.predict_bytes(_make_jpeg_bytes("RGB"))
    assert result.status == "unknown"
    assert result.material == "other"


def test_predictor_rejects_invalid_bytes_and_class_mismatch(tmp_path: Path) -> None:
    ckpt_path = _save_dummy_checkpoint(tmp_path)
    predictor = WasteClassifierPredictor(checkpoint_path=ckpt_path)

    with pytest.raises(InvalidImageError):
        predictor.predict_bytes(b"")
    with pytest.raises(InvalidImageError):
        predictor.predict_bytes(b"not-an-image-at-all")

    bad_dir = tmp_path / "bad_classes"
    bad_dir.mkdir()
    bad_ckpt = _save_dummy_checkpoint(
        bad_dir,
        classes=("paper", "plastic", "glass", "metal", "cardboard", "other"),
    )
    with pytest.raises(ArtifactContractError):
        WasteClassifierPredictor(checkpoint_path=bad_ckpt)
