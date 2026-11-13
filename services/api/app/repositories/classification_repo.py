from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.classification import Classification


class ClassificationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        user_id: str,
        predicted_material: str,
        confidence: float | None,
        confirmed_material: str,
        model_version: str,
    ) -> Classification:
        record = Classification(
            user_id=user_id,
            predicted_material=predicted_material,
            confidence=confidence,
            confirmed_material=confirmed_material,
            model_version=model_version,
        )
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record

    def get_by_id(self, classification_id: str) -> Classification | None:
        return self.db.get(Classification, classification_id)

    def list_for_user(
        self,
        *,
        user_id: str,
        material: str | None = None,
        limit: int = 20,
        offset: int = 0,
    ) -> tuple[list[Classification], int]:
        filters = [Classification.user_id == user_id]
        if material is not None:
            filters.append(Classification.confirmed_material == material)

        count_stmt = select(func.count()).select_from(Classification).where(*filters)
        total = self.db.scalar(count_stmt) or 0

        items_stmt = (
            select(Classification)
            .where(*filters)
            .order_by(Classification.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        items = list(self.db.scalars(items_stmt).all())
        return items, total

    def update_confirmed_material(
        self,
        record: Classification,
        confirmed_material: str,
    ) -> Classification:
        record.confirmed_material = confirmed_material
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record

    def delete(self, record: Classification) -> None:
        self.db.delete(record)
        self.db.commit()
