from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.classification import (
    ClassificationCreate,
    ClassificationListResponse,
    ClassificationResponse,
    ClassificationUpdate,
    MaterialKey,
)
from app.services.classification_service import ClassificationService

router = APIRouter(prefix="/classifications", tags=["classifications"])


@router.post("", response_model=ClassificationResponse, status_code=status.HTTP_201_CREATED)
def create_classification(
    payload: ClassificationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ClassificationResponse:
    return ClassificationService(db).create(user=current_user, payload=payload)


@router.get("", response_model=ClassificationListResponse)
def list_classifications(
    material: MaterialKey | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ClassificationListResponse:
    return ClassificationService(db).list_own(
        user=current_user,
        material=material,
        limit=limit,
        offset=offset,
    )


@router.get("/{classification_id}", response_model=ClassificationResponse)
def get_classification(
    classification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ClassificationResponse:
    return ClassificationService(db).get_one(
        user=current_user,
        classification_id=classification_id,
    )


@router.patch("/{classification_id}", response_model=ClassificationResponse)
def update_classification(
    classification_id: str,
    payload: ClassificationUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ClassificationResponse:
    return ClassificationService(db).update(
        user=current_user,
        classification_id=classification_id,
        payload=payload,
    )


@router.delete("/{classification_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_classification(
    classification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    ClassificationService(db).delete(
        user=current_user,
        classification_id=classification_id,
    )
