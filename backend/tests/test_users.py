def test_get_profile(client, auth_headers):
    response = client.get("/api/v1/users/profile", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "athlete@gymcoach.com"
    assert data["full_name"] == "Test Athlete"

def test_get_profile_unauthorized(client):
    response = client.get("/api/v1/users/profile")
    assert response.status_code == 401

def test_update_profile(client, auth_headers):
    update_payload = {
        "full_name": "Updated Athlete Name",
        "gender": "Female",
        "height_cm": 168.5,
        "weight_kg": 62.0,
    }
    response = client.put(
        "/api/v1/users/profile",
        json=update_payload,
        headers=auth_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["full_name"] == "Updated Athlete Name"
    assert data["gender"] == "Female"
    assert data["height_cm"] == 168.5
    assert data["weight_kg"] == 62.0
