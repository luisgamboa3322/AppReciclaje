import json
from collections import Counter
from datetime import UTC, datetime, timedelta
from pathlib import Path

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.classification import Classification
from app.models.user import User
from app.schemas.admin import (
    AdminClassificationItem,
    AdminClassificationListResponse,
    AdminMlReportResponse,
    AdminSummaryResponse,
    AdminUserItem,
    AdminUserListResponse,
    DailyCountItem,
    MaterialCountItem,
    UserStatisticsResponse,
)
from app.schemas.classification import MaterialKey


def _as_utc(dt: datetime) -> datetime:
    if dt.tzinfo is None:
        return dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


def _build_material_breakdown(rows: list[Classification]) -> list[MaterialCountItem]:
    total = len(rows)
    counts = Counter(row.confirmed_material for row in rows)
    return [
        MaterialCountItem(
            material=material,
            count=counts.get(material.value, 0),
            percentage=round((counts.get(material.value, 0) / total) * 100, 2) if total else 0.0,
        )
        for material in MaterialKey
    ]


def _build_daily_series(rows: list[Classification], days: int = 7) -> list[DailyCountItem]:
    today = datetime.now(UTC).date()
    day_keys = [(today - timedelta(days=offset)).isoformat() for offset in range(days - 1, -1, -1)]
    counts = Counter(_as_utc(row.created_at).date().isoformat() for row in rows)
    return [DailyCountItem(date=day, count=counts.get(day, 0)) for day in day_keys]


def _average_confidence(rows: list[Classification]) -> float | None:
    confidences = [row.confidence for row in rows if row.confidence is not None]
    if not confidences:
        return None
    return round(sum(confidences) / len(confidences), 4)


def _to_admin_classification_item(
    classification: Classification,
    user: User,
) -> AdminClassificationItem:
    return AdminClassificationItem(
        id=classification.id,
        user_id=classification.user_id,
        user_name=user.name,
        user_email=user.email,
        predicted_material=MaterialKey(classification.predicted_material),
        confidence=classification.confidence,
        confirmed_material=MaterialKey(classification.confirmed_material),
        model_version=classification.model_version,
        is_corrected=classification.predicted_material != classification.confirmed_material,
        created_at=_as_utc(classification.created_at),
        updated_at=_as_utc(classification.updated_at),
    )


def _find_ml_reports_dir() -> Path | None:
    current = Path(__file__).resolve()
    for parent in current.parents:
        candidate = parent / "ml" / "evaluation" / "reports"
        if candidate.is_dir():
            return candidate
    return None


class AnalyticsService:
    """Service layer for user statistics, admin aggregations, and RBAC administration."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def get_user_statistics(self, *, user: User) -> UserStatisticsResponse:
        rows = list(
            self.db.scalars(
                select(Classification)
                .where(Classification.user_id == user.id)
                .order_by(Classification.created_at.desc())
            ).all()
        )
        corrected_count = sum(1 for row in rows if row.predicted_material != row.confirmed_material)
        return UserStatisticsResponse(
            total_classifications=len(rows),
            corrected_count=corrected_count,
            average_confidence=_average_confidence(rows),
            by_material=_build_material_breakdown(rows),
            daily_last_7_days=_build_daily_series(rows, days=7),
        )

    def get_admin_summary(self) -> AdminSummaryResponse:
        users = list(self.db.scalars(select(User)).all())
        user_by_id = {u.id: u for u in users}
        classifications = list(
            self.db.scalars(
                select(Classification).order_by(Classification.created_at.desc())
            ).all()
        )

        seven_days_ago = datetime.now(UTC) - timedelta(days=7)
        recent_7d_count = sum(
            1 for row in classifications if _as_utc(row.created_at) >= seven_days_ago
        )
        corrected_count = sum(
            1 for row in classifications if row.predicted_material != row.confirmed_material
        )
        total_classifications = len(classifications)
        correction_rate = (
            round((corrected_count / total_classifications) * 100, 2)
            if total_classifications
            else 0.0
        )

        recent_items = [
            _to_admin_classification_item(row, user_by_id[row.user_id])
            for row in classifications[:8]
            if row.user_id in user_by_id
        ]

        return AdminSummaryResponse(
            total_users=len(users),
            total_admins=sum(1 for u in users if u.role == "admin"),
            total_classifications=total_classifications,
            classifications_last_7_days=recent_7d_count,
            corrected_count=corrected_count,
            correction_rate=correction_rate,
            average_confidence=_average_confidence(classifications),
            by_material=_build_material_breakdown(classifications),
            daily_last_7_days=_build_daily_series(classifications, days=7),
            recent_classifications=recent_items,
        )

    def list_admin_classifications(
        self,
        *,
        material: MaterialKey | None,
        user_id: str | None,
        corrected_only: bool,
        search: str | None,
        limit: int,
        offset: int,
    ) -> AdminClassificationListResponse:
        base_stmt = select(Classification, User).join(User, Classification.user_id == User.id)

        if material is not None:
            base_stmt = base_stmt.where(Classification.confirmed_material == material.value)
        if user_id is not None:
            base_stmt = base_stmt.where(Classification.user_id == user_id)
        if corrected_only:
            base_stmt = base_stmt.where(
                Classification.predicted_material != Classification.confirmed_material
            )
        if search:
            pattern = f"%{search.strip()}%"
            base_stmt = base_stmt.where(
                User.name.ilike(pattern)
                | User.email.ilike(pattern)
                | Classification.model_version.ilike(pattern)
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total = int(self.db.scalar(count_stmt) or 0)

        rows = self.db.execute(
            base_stmt.order_by(Classification.created_at.desc()).limit(limit).offset(offset)
        ).all()

        items = [
            _to_admin_classification_item(classification, user)
            for classification, user in rows
        ]
        return AdminClassificationListResponse(
            items=items,
            total=total,
            limit=limit,
            offset=offset,
        )

    def list_admin_users(
        self,
        *,
        role: str | None,
        search: str | None,
        limit: int,
        offset: int,
    ) -> AdminUserListResponse:
        stmt = select(User)
        if role in {"user", "admin"}:
            stmt = stmt.where(User.role == role)
        if search:
            pattern = f"%{search.strip()}%"
            stmt = stmt.where(User.name.ilike(pattern) | User.email.ilike(pattern))

        total = int(self.db.scalar(select(func.count()).select_from(stmt.subquery())) or 0)
        users = list(
            self.db.scalars(stmt.order_by(User.created_at.desc()).limit(limit).offset(offset)).all()
        )

        user_ids = [u.id for u in users]
        counts_by_user: dict[str, int] = {}
        if user_ids:
            count_rows = self.db.execute(
                select(Classification.user_id, func.count(Classification.id))
                .where(Classification.user_id.in_(user_ids))
                .group_by(Classification.user_id)
            ).all()
            counts_by_user = {uid: int(cnt) for uid, cnt in count_rows}

        items = [
            AdminUserItem(
                id=u.id,
                name=u.name,
                email=u.email,
                role="admin" if u.role == "admin" else "user",
                classifications_count=counts_by_user.get(u.id, 0),
                created_at=_as_utc(u.created_at),
            )
            for u in users
        ]
        return AdminUserListResponse(
            items=items,
            total=total,
            limit=limit,
            offset=offset,
        )

    def update_user_role(
        self,
        *,
        actor: User,
        target_user_id: str,
        role: str,
    ) -> AdminUserItem:
        target = self.db.get(User, target_user_id)
        if target is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )
        if actor.id == target.id and role != "admin":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Administrators cannot revoke their own admin role.",
            )

        target.role = role
        self.db.add(target)
        self.db.commit()
        self.db.refresh(target)

        classifications_count = int(
            self.db.scalar(
                select(func.count(Classification.id)).where(Classification.user_id == target.id)
            )
            or 0
        )
        return AdminUserItem(
            id=target.id,
            name=target.name,
            email=target.email,
            role="admin" if target.role == "admin" else "user",
            classifications_count=classifications_count,
            created_at=_as_utc(target.created_at),
        )

    @staticmethod
    def get_ml_evaluation_report() -> AdminMlReportResponse:
        reports_dir = _find_ml_reports_dir()
        if reports_dir is None:
            return AdminMlReportResponse(
                available=False,
                note="Evaluation reports directory was not found in this deployment.",
            )

        metrics_path = reports_dir / "metrics.json"
        eda_path = reports_dir / "eda_report.json"

        metrics_data = (
            json.loads(metrics_path.read_text(encoding="utf-8"))
            if metrics_path.is_file()
            else None
        )
        eda_data = (
            json.loads(eda_path.read_text(encoding="utf-8"))
            if eda_path.is_file()
            else None
        )

        if metrics_data is None and eda_data is None:
            return AdminMlReportResponse(
                available=False,
                note="No generated metrics.json or eda_report.json files found.",
            )

        return AdminMlReportResponse(
            available=True,
            metrics=metrics_data,
            eda=eda_data,
            note="Loaded offline evaluation reports generated by the ML pipeline.",
        )
