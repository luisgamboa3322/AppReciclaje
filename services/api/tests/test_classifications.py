from fastapi.testclient import TestClient

from tests.conftest import register_and_get_headers


def test_classification_crud_and_manual_correction(client: TestClient) -> None:
    headers, _ = register_and_get_headers(
        client,
        name="Usuario Uno",
        email="uno@example.com",
    )

    # Create without confirmed_material defaults confirmed_material == predicted_material
    create_resp = client.post(
        "/api/v1/classifications",
        headers=headers,
        json={
            "predicted_material": "plastic",
            "confidence": 0.86,
            "model_version": "resnet18-v1",
        },
    )
    assert create_resp.status_code == 201
    created = create_resp.json()
    assert created["predicted_material"] == "plastic"
    assert created["confirmed_material"] == "plastic"
    assert created["is_corrected"] is False

    # Manual correction updates confirmed_material while preserving predicted_material
    patch_resp = client.patch(
        f"/api/v1/classifications/{created['id']}",
        headers=headers,
        json={"confirmed_material": "glass"},
    )
    assert patch_resp.status_code == 200
    patched = patch_resp.json()
    assert patched["predicted_material"] == "plastic"
    assert patched["confirmed_material"] == "glass"
    assert patched["is_corrected"] is True

    # Filter by material and pagination
    list_glass = client.get("/api/v1/classifications?material=glass", headers=headers)
    assert list_glass.status_code == 200
    assert list_glass.json()["total"] == 1

    list_metal = client.get("/api/v1/classifications?material=metal", headers=headers)
    assert list_metal.status_code == 200
    assert list_metal.json()["total"] == 0

    # Delete own record
    del_resp = client.delete(f"/api/v1/classifications/{created['id']}", headers=headers)
    assert del_resp.status_code == 204

    get_deleted = client.get(f"/api/v1/classifications/{created['id']}", headers=headers)
    assert get_deleted.status_code == 404


def test_cross_user_access_is_forbidden(client: TestClient) -> None:
    headers_a, _ = register_and_get_headers(client, name="User A", email="a@example.com")
    headers_b, _ = register_and_get_headers(client, name="User B", email="b@example.com")

    created_a = client.post(
        "/api/v1/classifications",
        headers=headers_a,
        json={
            "predicted_material": "metal",
            "confidence": 0.72,
            "model_version": "resnet18-v1",
        },
    ).json()
    cid = created_a["id"]

    # User B does not see User A's classification in list
    list_b = client.get("/api/v1/classifications", headers=headers_b)
    assert list_b.status_code == 200
    assert list_b.json()["total"] == 0

    # User B cannot read, patch, or delete User A's classification
    assert client.get(f"/api/v1/classifications/{cid}", headers=headers_b).status_code == 403
    assert (
        client.patch(
            f"/api/v1/classifications/{cid}",
            headers=headers_b,
            json={"confirmed_material": "paper"},
        ).status_code
        == 403
    )
    assert client.delete(f"/api/v1/classifications/{cid}", headers=headers_b).status_code == 403

    # Unauthenticated user cannot access private classifications
    assert client.get("/api/v1/classifications").status_code == 401
