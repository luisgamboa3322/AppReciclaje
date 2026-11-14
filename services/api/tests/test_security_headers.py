import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings


def test_security_headers_attached_on_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.headers["x-content-type-options"] == "nosniff"
    assert response.headers["x-frame-options"] == "DENY"
    assert response.headers["referrer-policy"] == "strict-origin-when-cross-origin"


def test_production_rejects_default_or_short_jwt_secret() -> None:
    with pytest.raises(ValueError, match="JWT_SECRET_KEY"):
        Settings(app_env="production", jwt_secret_key="dev-only-change-before-production")

    with pytest.raises(ValueError, match="JWT_SECRET_KEY"):
        Settings(app_env="production", jwt_secret_key="short-secret")

    valid = Settings(
        app_env="production",
        jwt_secret_key="a_very_strong_random_production_secret_key_with_32_plus_chars",
    )
    assert valid.app_env == "production"
    assert valid.ml_use_tta is False

    with_tta = Settings(
        app_env="production",
        jwt_secret_key="a_very_strong_random_production_secret_key_with_32_plus_chars",
        ml_use_tta=True,
    )
    assert with_tta.ml_use_tta is True
