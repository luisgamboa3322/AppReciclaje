from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.classification import MaterialKey


class HealthResponse(BaseModel):
    status: str
    database: str
    environment: str


class ModelInfoResponse(BaseModel):
    status: str
    active_version: str | None
    architecture: str | None
    identified_threshold: float | None = None
    low_confidence_threshold: float | None = None
    note: str


class PredictAlternativeResponse(BaseModel):
    material: MaterialKey
    confidence: float = Field(ge=0.0, le=1.0)


class PredictResponse(BaseModel):
    prediction_id: str
    material: MaterialKey
    confidence: float = Field(ge=0.0, le=1.0)
    alternatives: list[PredictAlternativeResponse]
    model_version: str
    architecture: str
    status: Literal["identified", "low_confidence", "unknown"]
    inference_ms: float = Field(ge=0.0)
