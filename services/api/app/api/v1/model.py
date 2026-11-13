from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import get_settings
from app.core.database import get_db
from app.models.user import User
from app.repositories.guide_repo import ModelVersionRepository
from app.schemas.classification import MaterialKey
from app.schemas.health import (
    ModelInfoResponse,
    PredictAlternativeResponse,
    PredictResponse,
)
from app.services.ml_service import (
    ApiInvalidImageError,
    PredictorProtocol,
    get_predictor,
)

router = APIRouter(tags=["ml"])

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}


@router.get("/model/info", response_model=ModelInfoResponse)
def model_info(
    db: Session = Depends(get_db),
    predictor: PredictorProtocol | None = Depends(get_predictor),
) -> ModelInfoResponse:
    if predictor is not None:
        return ModelInfoResponse(
            status="ready",
            active_version=predictor.version,
            architecture=predictor.architecture,
            identified_threshold=predictor.identified_threshold,
            low_confidence_threshold=predictor.low_confidence_threshold,
            note="Trained PyTorch model artifact loaded in process memory.",
        )

    active = ModelVersionRepository(db).get_active()
    if active is not None:
        return ModelInfoResponse(
            status="registered_not_loaded",
            active_version=active.version,
            architecture=active.architecture,
            note="Model version is registered in DB, but no checkpoint is loaded yet.",
        )

    return ModelInfoResponse(
        status="not_trained_yet",
        active_version=None,
        architecture=None,
        note="No trained ML model artifact is configured or loaded.",
    )


@router.post("/predict", response_model=PredictResponse)
async def predict_material(
    file: UploadFile = File(...),
    _: User = Depends(get_current_user),
    predictor: PredictorProtocol | None = Depends(get_predictor),
) -> PredictResponse:
    """Validate uploaded image and classify waste material via loaded ML predictor."""
    settings = get_settings()
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Allowed: image/jpeg, image/png, image/webp.",
        )

    contents = await file.read(settings.max_image_upload_bytes + 1)
    if not contents:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded image file is empty.",
        )
    if len(contents) > settings.max_image_upload_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            detail=f"Image exceeds maximum allowed size of {settings.max_image_upload_mb} MB.",
        )

    if predictor is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="ML inference model is not configured or loaded yet.",
        )

    try:
        prediction = predictor.predict_bytes(contents)
    except ApiInvalidImageError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid or corrupted image file: {exc}",
        ) from exc

    return PredictResponse(
        prediction_id=prediction.prediction_id,
        material=MaterialKey(prediction.material),
        confidence=prediction.confidence,
        alternatives=[
            PredictAlternativeResponse(
                material=MaterialKey(alt.material),
                confidence=alt.confidence,
            )
            for alt in prediction.alternatives
        ],
        model_version=prediction.model_version,
        architecture=prediction.architecture,
        status=prediction.status,
        inference_ms=prediction.inference_ms,
    )
