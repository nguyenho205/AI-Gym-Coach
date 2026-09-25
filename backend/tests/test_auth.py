def test_register_success(client):
    response = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "John Doe",
            "email": "john@example.com",
            "password": "StrongPassword123!",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data
    assert data["user"]["email"] == "john@example.com"
    assert data["user"]["full_name"] == "John Doe"

def test_register_duplicate_email(client):
    payload = {
        "full_name": "First User",
        "email": "duplicate@example.com",
        "password": "Password123!",
    }
    resp1 = client.post("/api/v1/auth/register", json=payload)
    assert resp1.status_code == 200

    resp2 = client.post("/api/v1/auth/register", json=payload)
    assert resp2.status_code == 400
    assert "already exists" in resp2.json()["detail"]

def test_login_success(client):
    # Register first
    client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Login User",
            "email": "login@example.com",
            "password": "SecretPassword123",
        },
    )

    # Login
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "login@example.com",
            "password": "SecretPassword123",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data
    assert data["user"]["email"] == "login@example.com"

def test_login_invalid_password(client):
    client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Test User",
            "email": "user@example.com",
            "password": "CorrectPassword123",
        },
    )

    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "user@example.com",
            "password": "WrongPassword",
        },
    )
    assert response.status_code == 401
    assert "Invalid email or password" in response.json()["detail"]
