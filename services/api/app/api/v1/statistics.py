from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.admin import UserStatisticsResponse
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/statistics", tags=["statistics"])


@router.get("/me", response_model=UserStatisticsResponse)
def get_my_statistics(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserStatisticsResponse:
    return AnalyticsService(db).get_user_statistics(user=current_user)
