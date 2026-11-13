from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.user import User
from tests.conftest import register_and_get_headers


def _promote_to_admin(db_session: Session, user_id: str) -> None:
    user = db_session.get(User, user_id)
    assert user is not None
    user.role = "admin"
    db_session.add(user)
    db_session.commit()


def test_personal_statistics_and_admin_rbac_isolation(
    client: TestClient,
    db_session: Session,
) -> None:
    assert client.get("/api/v1/statistics/me").status_code == 401
    assert client.get("/api/v1/admin/summary").status_code == 401

    user_headers, user_auth = register_and_get_headers(
        client,
        name="Luis Reciclador",
        email="luis@example.com",
    )
    admin_headers, admin_auth = register_and_get_headers(
        client,
        name="Admin PECOX",
        email="admin@example.com",
    )
    _promote_to_admin(db_session, admin_auth["user"]["id"])

    # Standard user creates 2 classifications (1 corrected, 1 unchanged)
    c1 = client.post(
        "/api/v1/classifications",
        headers=user_headers,
        json={
            "predicted_material": "plastic",
            "confidence": 0.90,
            "confirmed_material": "plastic",
            "model_version": "resnet18-trashnet-v1.0.0",
        },
    )
    assert c1.status_code == 201
    c2 = client.post(
        "/api/v1/classifications",
        headers=user_headers,
        json={
            "predicted_material": "glass",
            "confidence": 0.60,
            "confirmed_material": "metal",
            "model_version": "resnet18-trashnet-v1.0.0",
        },
    )
    assert c2.status_code == 201

    # Admin creates 1 classification
    c3 = client.post(
        "/api/v1/classifications",
        headers=admin_headers,
        json={
            "predicted_material": "paper",
            "confidence": 0.84,
            "confirmed_material": "paper",
            "model_version": "resnet18-trashnet-v1.0.0",
        },
    )
    assert c3.status_code == 201

    # Personal stats see only standard user's 2 classifications
    my_stats_resp = client.get("/api/v1/statistics/me", headers=user_headers)
    assert my_stats_resp.status_code == 200
    my_stats = my_stats_resp.json()
    assert my_stats["total_classifications"] == 2
    assert my_stats["corrected_count"] == 1
    assert my_stats["average_confidence"] == 0.75
    assert len(my_stats["daily_last_7_days"]) == 7

    # Standard user is blocked from all admin endpoints
    for method, path in [
        ("GET", "/api/v1/admin/summary"),
        ("GET", "/api/v1/admin/classifications"),
        ("GET", "/api/v1/admin/users"),
        ("GET", "/api/v1/admin/ml-report"),
    ]:
        forbidden = client.request(method, path, headers=user_headers)
        assert forbidden.status_code == 403, f"Expected 403 on {path}"

    role_forbidden = client.patch(
        f"/api/v1/admin/users/{user_auth['user']['id']}/role",
        headers=user_headers,
        json={"role": "admin"},
    )
    assert role_forbidden.status_code == 403

    # Admin reads global summary
    summary_resp = client.get("/api/v1/admin/summary", headers=admin_headers)
    assert summary_resp.status_code == 200
    summary = summary_resp.json()
    assert summary["total_users"] == 2
    assert summary["total_admins"] == 1
    assert summary["total_classifications"] == 3
    assert summary["classifications_last_7_days"] == 3
    assert summary["corrected_count"] == 1
    assert summary["correction_rate"] == 33.33
    assert summary["average_confidence"] == 0.78
    assert len(summary["recent_classifications"]) == 3

    # Filter admin classifications (corrected_only + material)
    corrected_resp = client.get(
        "/api/v1/admin/classifications",
        headers=admin_headers,
        params={"corrected_only": True},
    )
    assert corrected_resp.status_code == 200
    corrected_data = corrected_resp.json()
    assert corrected_data["total"] == 1
    assert corrected_data["items"][0]["confirmed_material"] == "metal"
    assert corrected_data["items"][0]["user_email"] == "luis@example.com"

    # Admin lists users and never receives password hashes
    users_resp = client.get("/api/v1/admin/users", headers=admin_headers)
    assert users_resp.status_code == 200
    users_data = users_resp.json()
    assert users_data["total"] == 2
    for item in users_data["items"]:
        assert "password_hash" not in item

    # Admin promotes user, cannot demote self
    promote_resp = client.patch(
        f"/api/v1/admin/users/{user_auth['user']['id']}/role",
        headers=admin_headers,
        json={"role": "admin"},
    )
    assert promote_resp.status_code == 200
    assert promote_resp.json()["role"] == "admin"

    self_demote = client.patch(
        f"/api/v1/admin/users/{admin_auth['user']['id']}/role",
        headers=admin_headers,
        json={"role": "user"},
    )
    assert self_demote.status_code == 400

    # Admin reads ML offline report
    ml_report = client.get("/api/v1/admin/ml-report", headers=admin_headers)
    assert ml_report.status_code == 200
    ml_json = ml_report.json()
    assert ml_json["available"] is True
    assert ml_json["metrics"]["accuracy"] == 0.8975
