from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import get_settings
from app.core.database import get_db
from app.models.user import User
from app.repositories.guide_repo import ModelVersionRepository
from app.schemas.health import ModelInfoResponse

router = APIRouter(tags=["ml"])

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}


@router.get("/model/info", response_model=ModelInfoResponse)
def model_info(db: Session = Depends(get_db)) -> ModelInfoResponse:
    active = ModelVersionRepository(db).get_active()
    if active is None:
        return ModelInfoResponse(
            status="not_trained_yet",
            active_version=None,
            architecture=None,
            note="No trained ML model artifact is loaded yet (planned for Phase 3).",
        )
    return ModelInfoResponse(
        status="ready",
        active_version=active.version,
        architecture=active.architecture,
        note="Active model version registered in database.",
    )


@router.post("/predict", status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
async def predict_material(
    file: UploadFile = File(...),
    _: User = Depends(get_current_user),
) -> dict:
    """Validate uploaded image contract; ML inference will be connected in Phase 3."""
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

    raise HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="ML inference model is not connected yet (planned for Phase 3).",
    )
