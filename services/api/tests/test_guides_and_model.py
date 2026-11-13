from fastapi.testclient import TestClient

from tests.conftest import register_and_get_headers


def test_public_guides_and_honest_model_endpoints(client: TestClient) -> None:
    guides_resp = client.get("/api/v1/guides")
    assert guides_resp.status_code == 200
    guides = guides_resp.json()
    assert len(guides) == 6
    keys = {g["material_key"] for g in guides}
    assert keys == {"plastic", "glass", "metal", "cardboard", "paper", "other"}

    info_resp = client.get("/api/v1/model/info")
    assert info_resp.status_code == 200
    assert info_resp.json()["status"] == "not_trained_yet"
    assert info_resp.json()["active_version"] is None

    headers, _ = register_and_get_headers(client, name="Tester", email="tester@example.com")

    # Invalid file content-type returns 400
    bad_upload = client.post(
        "/api/v1/predict",
        headers=headers,
        files={"file": ("notes.txt", b"not-an-image", "text/plain")},
    )
    assert bad_upload.status_code == 400

    # Valid image upload returns honest 503 before Phase 3 model exists
    valid_upload = client.post(
        "/api/v1/predict",
        headers=headers,
        files={"file": ("bottle.jpg", b"\xff\xd8\xff\xe0dummyjpeg", "image/jpeg")},
    )
    assert valid_upload.status_code == 503
