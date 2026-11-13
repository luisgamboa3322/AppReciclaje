from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, EmailStr

from app.schemas.classification import MaterialKey


class MaterialCountItem(BaseModel):
    material: MaterialKey
    count: int
    percentage: float


class DailyCountItem(BaseModel):
    date: str
    count: int


class UserStatisticsResponse(BaseModel):
    total_classifications: int
    corrected_count: int
    average_confidence: float | None
    by_material: list[MaterialCountItem]
    daily_last_7_days: list[DailyCountItem]


class AdminClassificationItem(BaseModel):
    id: str
    user_id: str
    user_name: str
    user_email: EmailStr
    predicted_material: MaterialKey
    confidence: float | None
    confirmed_material: MaterialKey
    model_version: str
    is_corrected: bool
    created_at: datetime
    updated_at: datetime


class AdminClassificationListResponse(BaseModel):
    items: list[AdminClassificationItem]
    total: int
    limit: int
    offset: int


class AdminUserItem(BaseModel):
    id: str
    name: str
    email: EmailStr
    role: Literal["user", "admin"]
    classifications_count: int
    created_at: datetime


class AdminUserListResponse(BaseModel):
    items: list[AdminUserItem]
    total: int
    limit: int
    offset: int


class AdminRoleUpdateRequest(BaseModel):
    role: Literal["user", "admin"]


class AdminSummaryResponse(BaseModel):
    total_users: int
    total_admins: int
    total_classifications: int
    classifications_last_7_days: int
    corrected_count: int
    correction_rate: float
    average_confidence: float | None
    by_material: list[MaterialCountItem]
    daily_last_7_days: list[DailyCountItem]
    recent_classifications: list[AdminClassificationItem]


class AdminMlReportResponse(BaseModel):
    available: bool
    metrics: dict[str, Any] | None = None
    eda: dict[str, Any] | None = None
    note: str | None = None
