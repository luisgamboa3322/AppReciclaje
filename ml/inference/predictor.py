"""Single-load PyTorch inference engine with explicit uncertainty status."""

from __future__ import annotations

import io
import json
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import torch
from PIL import Image, ImageOps, UnidentifiedImageError

from ml.training.constants import (
    CANONICAL_CLASSES,
    DEFAULT_IDENTIFIED_THRESHOLD,
    DEFAULT_LOW_CONFIDENCE_THRESHOLD,
    INPUT_IMAGE_SIZE,
)
from ml.training.models import build_classifier
from ml.training.transforms import build_eval_transform

PredictionStatus = Literal["identified", "low_confidence", "unknown"]


class InvalidImageError(ValueError):
    """Raised when uploaded bytes cannot be decoded into a valid RGB image."""


class ArtifactContractError(RuntimeError):
    """Raised when checkpoint metadata or canonical class ordering is invalid."""


@dataclass(frozen=True)
class AlternativePrediction:
    material: str
    confidence: float


@dataclass(frozen=True)
class PredictionResult:
    prediction_id: str
    material: str
    confidence: float
    alternatives: list[AlternativePrediction]
    model_version: str
    architecture: str
    status: PredictionStatus
    inference_ms: float


class WasteClassifierPredictor:
    """Thread-safe inference wrapper loaded once per API worker process."""

    def __init__(
        self,
        checkpoint_path: Path,
        metadata_path: Path | None = None,
        identified_threshold: float | None = None,
        low_confidence_threshold: float | None = None,
        use_tta: bool = False,
    ) -> None:
        if not checkpoint_path.is_file():
            raise FileNotFoundError(f"ML checkpoint not found: {checkpoint_path}")

        self.device = torch.device("cpu")
        checkpoint = torch.load(checkpoint_path, map_location=self.device, weights_only=True)

        classes = tuple(checkpoint.get("classes", ()))
        if classes != CANONICAL_CLASSES:
            raise ArtifactContractError(
                f"Checkpoint classes {classes} do not match canonical classes {CANONICAL_CLASSES}."
            )

        self.classes: tuple[str, ...] = classes
        self.architecture: str = str(checkpoint["architecture"])
        self.version: str = str(checkpoint["version"])
        self.image_size: int = int(checkpoint.get("image_size", INPUT_IMAGE_SIZE))

        metadata: dict = {}
        resolved_meta_path = metadata_path or (checkpoint_path.parent / "model_metadata.json")
        if resolved_meta_path.is_file():
            metadata = json.loads(resolved_meta_path.read_text(encoding="utf-8"))

        self.identified_threshold = float(
            identified_threshold
            if identified_threshold is not None
            else metadata.get("identified_threshold", DEFAULT_IDENTIFIED_THRESHOLD)
        )
        self.low_confidence_threshold = float(
            low_confidence_threshold
            if low_confidence_threshold is not None
            else metadata.get("low_confidence_threshold", DEFAULT_LOW_CONFIDENCE_THRESHOLD)
        )
        if self.low_confidence_threshold > self.identified_threshold:
            raise ArtifactContractError(
                "low_confidence_threshold cannot exceed identified_threshold"
            )

        self.model = build_classifier(
            architecture=self.architecture,
            num_classes=len(self.classes),
            pretrained=False,
        )
        self.model.load_state_dict(checkpoint["state_dict"])
        self.model.eval()
        self.use_tta = bool(use_tta)
        self.transform = build_eval_transform(self.image_size)

    def predict_pil(self, image: Image.Image, use_tta: bool | None = None) -> PredictionResult:
        """Run deterministic inference (with optional 2-view flip TTA) on a PIL Image."""
        started = time.perf_counter()
        rgb = ImageOps.exif_transpose(image).convert("RGB")
        tta_enabled = self.use_tta if use_tta is None else use_tta
        if tta_enabled:
            batch = torch.stack(
                [
                    self.transform(rgb),
                    self.transform(ImageOps.mirror(rgb)),
                ]
            ).to(self.device)
        else:
            batch = self.transform(rgb).unsqueeze(0).to(self.device)

        with torch.inference_mode():
            logits = self.model(batch)
            probs = torch.softmax(logits, dim=1).mean(dim=0).cpu().tolist()

        ranked = sorted(
            zip(self.classes, probs, strict=True),
            key=lambda item: item[1],
            reverse=True,
        )
        top_material, top_conf = ranked[0]

        if top_conf >= self.identified_threshold:
            status: PredictionStatus = "identified"
            predicted_material = top_material
            alt_source = ranked[1:3]
        elif top_conf >= self.low_confidence_threshold:
            status = "low_confidence"
            predicted_material = top_material
            alt_source = ranked[1:3]
        else:
            status = "unknown"
            # When probability mass is too diffuse across classes, avoid claiming a specific item.
            predicted_material = "other"
            alt_source = [pair for pair in ranked[:3] if pair[0] != "other"][:2]

        alternatives = [
            AlternativePrediction(material=mat, confidence=round(float(prob), 4))
            for mat, prob in alt_source
            if prob >= 0.01
        ]
        elapsed_ms = round((time.perf_counter() - started) * 1000, 2)

        return PredictionResult(
            prediction_id=str(uuid.uuid4()),
            material=predicted_material,
            confidence=round(float(top_conf), 4),
            alternatives=alternatives,
            model_version=self.version,
            architecture=self.architecture,
            status=status,
            inference_ms=elapsed_ms,
        )

    def predict_bytes(self, payload: bytes) -> PredictionResult:
        """Decode image bytes safely and classify material."""
        if not payload:
            raise InvalidImageError("Image payload is empty.")
        try:
            with Image.open(io.BytesIO(payload)) as img:
                img.verify()
            with Image.open(io.BytesIO(payload)) as img:
                return self.predict_pil(img)
        except (UnidentifiedImageError, OSError, ValueError) as exc:
            raise InvalidImageError(f"Corrupted or unreadable image bytes: {exc}") from exc
