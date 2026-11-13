"""Canonical class ordering, normalization constants, and dataset label mapping."""

from __future__ import annotations

CANONICAL_CLASSES: tuple[str, ...] = (
    "plastic",
    "glass",
    "metal",
    "cardboard",
    "paper",
    "other",
)

CLASS_TO_IDX: dict[str, int] = {label: idx for idx, label in enumerate(CANONICAL_CLASSES)}
IDX_TO_CLASS: dict[int, str] = {idx: label for idx, label in enumerate(CANONICAL_CLASSES)}

TRASHNET_TO_PECOX: dict[str, str] = {
    "plastic": "plastic",
    "glass": "glass",
    "metal": "metal",
    "cardboard": "cardboard",
    "paper": "paper",
    "trash": "other",
}

IMAGENET_MEAN: tuple[float, float, float] = (0.485, 0.456, 0.406)
IMAGENET_STD: tuple[float, float, float] = (0.229, 0.224, 0.225)
INPUT_IMAGE_SIZE: int = 224

# Default confidence thresholds; overridden per trained artifact after validation calibration.
DEFAULT_IDENTIFIED_THRESHOLD: float = 0.70
DEFAULT_LOW_CONFIDENCE_THRESHOLD: float = 0.45
