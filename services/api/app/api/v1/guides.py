from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.repositories.guide_repo import GuideRepository
from app.schemas.guide import MaterialGuideResponse

router = APIRouter(prefix="/guides", tags=["guides"])


@router.get("", response_model=list[MaterialGuideResponse])
def list_guides(db: Session = Depends(get_db)) -> list[MaterialGuideResponse]:
    guides = GuideRepository(db).list_all()
    return [MaterialGuideResponse.model_validate(item) for item in guides]
