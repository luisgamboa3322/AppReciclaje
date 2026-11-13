from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, ConfigDict, Field


class MaterialKey(StrEnum):
    PLASTIC = "plastic"
    GLASS = "glass"
    METAL = "metal"
    CARDBOARD = "cardboard"
    PAPER = "paper"
    OTHER = "other"


class ClassificationCreate(BaseModel):
    predicted_material: MaterialKey
    confidence: float | None = Field(default=None, ge=0.0, le=1.0)
    confirmed_material: MaterialKey | None = None
    model_version: str = Field(min_length=1, max_length=64)


class ClassificationUpdate(BaseModel):
    confirmed_material: MaterialKey


class ClassificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    predicted_material: MaterialKey
    confidence: float | None
    confirmed_material: MaterialKey
    model_version: str
    is_corrected: bool
    created_at: datetime
    updated_at: datetime

    @classmethod
    def from_orm_model(cls, obj) -> "ClassificationResponse":
        return cls(
            id=obj.id,
            user_id=obj.user_id,
            predicted_material=MaterialKey(obj.predicted_material),
            confidence=obj.confidence,
            confirmed_material=MaterialKey(obj.confirmed_material),
            model_version=obj.model_version,
            is_corrected=obj.predicted_material != obj.confirmed_material,
            created_at=obj.created_at,
            updated_at=obj.updated_at,
        )


class ClassificationListResponse(BaseModel):
    items: list[ClassificationResponse]
    total: int
    limit: int
    offset: int
