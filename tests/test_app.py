from app import app


def test_home_page():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200


def test_health_status_code():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200


def test_health_json():
    client = app.test_client()
    data = client.get("/health").get_json()
    assert data["status"] == "healthy"
    assert data["application"] == "running"
