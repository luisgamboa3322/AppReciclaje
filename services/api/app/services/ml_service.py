"""Lazy single-load bridge between FastAPI and ml.inference.predictor."""

from __future__ import annotations

import logging
import sys
from functools import lru_cache
from pathlib import Path
from typing import Any, Protocol

from app.core.config import get_settings

logger = logging.getLogger("pecox.ml")


class ApiInvalidImageError(ValueError):
    """Raised when uploaded bytes fail image verification."""


class PredictorProtocol(Protocol):
    version: str
    architecture: str
    identified_threshold: float
    low_confidence_threshold: float

    def predict_bytes(self, payload: bytes) -> Any: ...


def _ensure_repo_on_syspath() -> None:
    # Repo root is four levels above services/api/app/services/ml_service.py.
    repo_root = Path(__file__).resolve().parents[4]
    repo_str = str(repo_root)
    if (repo_root / "ml").is_dir() and repo_str not in sys.path:
        sys.path.insert(0, repo_str)


@lru_cache(maxsize=1)
def _load_predictor_cached(
    artifact_dir_str: str,
    use_tta: bool = False,
) -> PredictorProtocol | None:
    if not artifact_dir_str.strip():
        return None

    artifact_dir = Path(artifact_dir_str)
    checkpoint_path = artifact_dir / "best_checkpoint.pt"
    if not checkpoint_path.is_file():
        logger.warning("ML checkpoint not found at %s; returning unavailable.", checkpoint_path)
        return None

    _ensure_repo_on_syspath()
    try:
        from ml.inference.predictor import (
            InvalidImageError,
            WasteClassifierPredictor,
        )
    except ImportError as exc:
        logger.warning("ML dependencies unavailable in current environment: %s", exc)
        return None

    predictor = WasteClassifierPredictor(
        checkpoint_path=checkpoint_path,
        metadata_path=artifact_dir / "model_metadata.json",
        use_tta=use_tta,
    )

    class _Adapter:
        def __init__(self, inner: WasteClassifierPredictor) -> None:
            self._inner = inner
            self.version = inner.version
            self.architecture = inner.architecture
            self.identified_threshold = inner.identified_threshold
            self.low_confidence_threshold = inner.low_confidence_threshold

        def predict_bytes(self, payload: bytes) -> Any:
            try:
                return self._inner.predict_bytes(payload)
            except InvalidImageError as exc:
                raise ApiInvalidImageError(str(exc)) from exc

    logger.info(
        "Loaded PECOX ML predictor version=%s arch=%s",
        predictor.version,
        predictor.architecture,
    )
    return _Adapter(predictor)


def get_predictor() -> PredictorProtocol | None:
    """FastAPI dependency returning the loaded single-process predictor or None."""
    settings = get_settings()
    return _load_predictor_cached(settings.ml_artifact_dir, use_tta=settings.ml_use_tta)


def clear_predictor_cache() -> None:
    """Reset cached predictor singleton (used in tests or artifact rotation)."""
    _load_predictor_cached.cache_clear()
