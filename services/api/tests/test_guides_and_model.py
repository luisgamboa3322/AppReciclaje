from dataclasses import dataclass

from fastapi.testclient import TestClient

from app.services.ml_service import ApiInvalidImageError, get_predictor
from tests.conftest import register_and_get_headers


@dataclass(frozen=True)
class _FakeAlt:
    material: str
    confidence: float


@dataclass(frozen=True)
class _FakePrediction:
    prediction_id: str
    material: str
    confidence: float
    alternatives: list[_FakeAlt]
    model_version: str
    architecture: str
    status: str
    inference_ms: float


class _FakePredictor:
    version = "resnet18-test-v1.0.0"
    architecture = "resnet18"
    identified_threshold = 0.70
    low_confidence_threshold = 0.45

    def predict_bytes(self, payload: bytes) -> _FakePrediction:
        if payload == b"corrupt-bytes":
            raise ApiInvalidImageError("cannot identify image file")
        return _FakePrediction(
            prediction_id="pred-123",
            material="plastic",
            confidence=0.88,
            alternatives=[_FakeAlt(material="glass", confidence=0.07)],
            model_version=self.version,
            architecture=self.architecture,
            status="identified",
            inference_ms=14.2,
        )


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

    # Valid image upload returns honest 503 when no model artifact is loaded
    valid_upload = client.post(
        "/api/v1/predict",
        headers=headers,
        files={"file": ("bottle.jpg", b"\xff\xd8\xff\xe0dummyjpeg", "image/jpeg")},
    )
    assert valid_upload.status_code == 503


def test_predict_and_model_info_when_predictor_loaded(client: TestClient) -> None:
    headers, _ = register_and_get_headers(client, name="ML User", email="ml@example.com")
    client.app.dependency_overrides[get_predictor] = lambda: _FakePredictor()
    try:
        info_resp = client.get("/api/v1/model/info")
        assert info_resp.status_code == 200
        info_data = info_resp.json()
        assert info_data["status"] == "ready"
        assert info_data["active_version"] == "resnet18-test-v1.0.0"
        assert info_data["architecture"] == "resnet18"

        predict_resp = client.post(
            "/api/v1/predict",
            headers=headers,
            files={"file": ("bottle.jpg", b"\xff\xd8\xff\xe0validjpeg", "image/jpeg")},
        )
        assert predict_resp.status_code == 200
        pred = predict_resp.json()
        assert pred["material"] == "plastic"
        assert pred["confidence"] == 0.88
        assert pred["status"] == "identified"
        assert pred["model_version"] == "resnet18-test-v1.0.0"
        assert len(pred["alternatives"]) == 1

        corrupt_resp = client.post(
            "/api/v1/predict",
            headers=headers,
            files={"file": ("broken.jpg", b"corrupt-bytes", "image/jpeg")},
        )
        assert corrupt_resp.status_code == 400
    finally:
        client.app.dependency_overrides.pop(get_predictor, None)
