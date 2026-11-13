from typing import Literal

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import require_admin
from app.core.database import get_db
from app.models.user import User
from app.schemas.admin import (
    AdminClassificationListResponse,
    AdminMlReportResponse,
    AdminRoleUpdateRequest,
    AdminSummaryResponse,
    AdminUserItem,
    AdminUserListResponse,
)
from app.schemas.classification import MaterialKey
from app.services.analytics_service import AnalyticsService

router = APIRouter(
    prefix="/admin",
    tags=["admin"],
    dependencies=[Depends(require_admin)],
)


@router.get("/summary", response_model=AdminSummaryResponse)
def get_admin_summary(
    db: Session = Depends(get_db),
) -> AdminSummaryResponse:
    return AnalyticsService(db).get_admin_summary()


@router.get("/classifications", response_model=AdminClassificationListResponse)
def list_all_classifications(
    material: MaterialKey | None = Query(default=None),
    user_id: str | None = Query(default=None),
    corrected_only: bool = Query(default=False),
    search: str | None = Query(default=None, max_length=120),
    limit: int = Query(default=25, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db),
) -> AdminClassificationListResponse:
    return AnalyticsService(db).list_admin_classifications(
        material=material,
        user_id=user_id,
        corrected_only=corrected_only,
        search=search,
        limit=limit,
        offset=offset,
    )


@router.get("/users", response_model=AdminUserListResponse)
def list_users(
    role: Literal["user", "admin"] | None = Query(default=None),
    search: str | None = Query(default=None, max_length=120),
    limit: int = Query(default=25, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db),
) -> AdminUserListResponse:
    return AnalyticsService(db).list_admin_users(
        role=role,
        search=search,
        limit=limit,
        offset=offset,
    )


@router.patch("/users/{user_id}/role", response_model=AdminUserItem)
def update_user_role(
    user_id: str,
    payload: AdminRoleUpdateRequest,
    current_admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> AdminUserItem:
    return AnalyticsService(db).update_user_role(
        actor=current_admin,
        target_user_id=user_id,
        role=payload.role,
    )


@router.get("/ml-report", response_model=AdminMlReportResponse)
def get_ml_report() -> AdminMlReportResponse:
    return AnalyticsService.get_ml_evaluation_report()
