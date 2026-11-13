from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.classification import Classification
from app.models.user import User
from app.repositories.classification_repo import ClassificationRepository
from app.schemas.classification import (
    ClassificationCreate,
    ClassificationListResponse,
    ClassificationResponse,
    ClassificationUpdate,
    MaterialKey,
)


class ClassificationService:
    def __init__(self, db: Session) -> None:
        self.repo = ClassificationRepository(db)

    def create(self, *, user: User, payload: ClassificationCreate) -> ClassificationResponse:
        confirmed = payload.confirmed_material or payload.predicted_material
        record = self.repo.create(
            user_id=user.id,
            predicted_material=payload.predicted_material.value,
            confidence=payload.confidence,
            confirmed_material=confirmed.value,
            model_version=payload.model_version,
        )
        return ClassificationResponse.from_orm_model(record)

    def list_own(
        self,
        *,
        user: User,
        material: MaterialKey | None = None,
        limit: int = 20,
        offset: int = 0,
    ) -> ClassificationListResponse:
        items, total = self.repo.list_for_user(
            user_id=user.id,
            material=material.value if material is not None else None,
            limit=limit,
            offset=offset,
        )
        return ClassificationListResponse(
            items=[ClassificationResponse.from_orm_model(item) for item in items],
            total=total,
            limit=limit,
            offset=offset,
        )

    def _get_owned_record(self, *, user: User, classification_id: str) -> Classification:
        record = self.repo.get_by_id(classification_id)
        if record is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Classification not found.",
            )
        if record.user_id != user.id and user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to access this classification.",
            )
        return record

    def get_one(self, *, user: User, classification_id: str) -> ClassificationResponse:
        record = self._get_owned_record(user=user, classification_id=classification_id)
        return ClassificationResponse.from_orm_model(record)

    def update(
        self,
        *,
        user: User,
        classification_id: str,
        payload: ClassificationUpdate,
    ) -> ClassificationResponse:
        record = self._get_owned_record(user=user, classification_id=classification_id)
        updated = self.repo.update_confirmed_material(
            record,
            confirmed_material=payload.confirmed_material.value,
        )
        return ClassificationResponse.from_orm_model(updated)

    def delete(self, *, user: User, classification_id: str) -> None:
        record = self._get_owned_record(user=user, classification_id=classification_id)
        self.repo.delete(record)
