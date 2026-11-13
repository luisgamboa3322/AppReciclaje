from functools import lru_cache

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    app_name: str = "PECOX Vision API"
    app_env: str = "development"
    api_host: str = "127.0.0.1"
    api_port: int = 8000
    cors_origins: str = "http://localhost:3000,http://localhost:8443"

    database_url: str = "sqlite:///./pecox_dev.db"

    jwt_secret_key: str = "dev-only-change-before-production-32chars-minimum"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    ml_model_version: str = "not-connected-yet"
    ml_artifact_dir: str = ""
    ml_confidence_threshold: float = 0.65
    max_image_upload_mb: int = 10

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @model_validator(mode="after")
    def validate_production_secret(self) -> "Settings":
        if self.app_env.strip().lower() == "production":
            insecure_prefixes = ("dev-only", "replace_with", "change_me")
            if self.jwt_secret_key.startswith(insecure_prefixes) or len(self.jwt_secret_key) < 32:
                raise ValueError(
                    "Production APP_ENV requires a strong random JWT_SECRET_KEY (>= 32 chars)."
                )
        return self

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def max_image_upload_bytes(self) -> int:
        return self.max_image_upload_mb * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    return Settings()
