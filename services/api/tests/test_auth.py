from fastapi.testclient import TestClient

from tests.conftest import register_and_get_headers


def test_health_endpoint_ok(client: TestClient) -> None:
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert body["database"] == "connected"
    assert "X-Request-ID" in resp.headers


def test_register_login_refresh_and_me_flow(client: TestClient) -> None:
    headers, reg_data = register_and_get_headers(
        client,
        name="Sofía Martínez",
        email="sofia@example.com",
    )
    assert reg_data["user"]["email"] == "sofia@example.com"
    assert "password_hash" not in reg_data["user"]

    # Duplicate registration must return 409
    dup = client.post(
        "/api/v1/auth/register",
        json={"name": "Sofía", "email": "sofia@example.com", "password": "StrongPass123!"},
    )
    assert dup.status_code == 409

    # Login with valid credentials
    login_ok = client.post(
        "/api/v1/auth/login",
        json={"email": "sofia@example.com", "password": "StrongPass123!"},
    )
    assert login_ok.status_code == 200

    # Login with wrong password returns 401
    login_bad = client.post(
        "/api/v1/auth/login",
        json={"email": "sofia@example.com", "password": "WrongPassword"},
    )
    assert login_bad.status_code == 401

    # /users/me succeeds with access token and rejects missing/refresh token
    me_ok = client.get("/api/v1/users/me", headers=headers)
    assert me_ok.status_code == 200
    assert me_ok.json()["name"] == "Sofía Martínez"

    me_unauth = client.get("/api/v1/users/me")
    assert me_unauth.status_code == 401

    refresh_headers = {"Authorization": f"Bearer {reg_data['refresh_token']}"}
    me_with_refresh = client.get("/api/v1/users/me", headers=refresh_headers)
    assert me_with_refresh.status_code == 401

    # Refresh token issues a new token pair, while access token cannot refresh
    refresh_ok = client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": reg_data["refresh_token"]},
    )
    assert refresh_ok.status_code == 200
    assert "access_token" in refresh_ok.json()

    refresh_with_access = client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": reg_data["access_token"]},
    )
    assert refresh_with_access.status_code == 401
