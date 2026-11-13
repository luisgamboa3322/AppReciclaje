from fastapi import APIRouter, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.health import router as health_router
from app.api.v1.admin import router as admin_router
from app.api.v1.auth import router as auth_router
from app.api.v1.classifications import router as classifications_router
from app.api.v1.guides import router as guides_router
from app.api.v1.model import router as model_router
from app.api.v1.statistics import router as statistics_router
from app.api.v1.users import router as users_router
from app.core.config import get_settings
from app.core.logging import RequestContextMiddleware, configure_logging


def create_app() -> FastAPI:
    configure_logging()
    settings = get_settings()

    application = FastAPI(
        title=settings.app_name,
        version="0.2.0",
        description="REST API for PECOX Vision mobile and web clients.",
    )

    application.add_middleware(RequestContextMiddleware)
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origin_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.include_router(health_router)

    v1_router = APIRouter(prefix="/api/v1")
    v1_router.include_router(auth_router)
    v1_router.include_router(users_router)
    v1_router.include_router(classifications_router)
    v1_router.include_router(guides_router)
    v1_router.include_router(model_router)
    v1_router.include_router(statistics_router)
    v1_router.include_router(admin_router)

    application.include_router(v1_router)
    return application


app = create_app()
