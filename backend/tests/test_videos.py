import io

def test_upload_video_success(client, auth_headers):
    # Create fake mp4 byte content
    file_bytes = b"\x00\x00\x00\x18ftypmp42\x00\x00\x00\x00mp42isom" + b"A" * 1024
    video_file = io.BytesIO(file_bytes)

    response = client.post(
        "/api/v1/videos/upload",
        files={"video": ("sample_squat.mp4", video_file, "video/mp4")},
        data={"exercise_type": "squat"},
        headers=auth_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert "video_id" in data
    assert data["status"] == "uploaded"
    assert data["exercise_type"] == "squat"
    assert data["file_name"] == "sample_squat.mp4"

def test_upload_video_invalid_format(client, auth_headers):
    file_bytes = b"fake script contents"
    bad_file = io.BytesIO(file_bytes)

    response = client.post(
        "/api/v1/videos/upload",
        files={"video": ("malicious.exe", bad_file, "application/octet-stream")},
        data={"exercise_type": "squat"},
        headers=auth_headers,
    )
    assert response.status_code == 400
    assert "Unsupported video format" in response.json()["detail"]

def test_list_and_delete_video(client, auth_headers):
    file_bytes = b"\x00\x00\x00\x18ftypmp42" + b"X" * 512
    video_file = io.BytesIO(file_bytes)

    upload_resp = client.post(
        "/api/v1/videos/upload",
        files={"video": ("squat_clip.mp4", video_file, "video/mp4")},
        data={"exercise_type": "squat"},
        headers=auth_headers,
    )
    video_id = upload_resp.json()["video_id"]

    # List videos
    list_resp = client.get("/api/v1/videos", headers=auth_headers)
    assert list_resp.status_code == 200
    videos = list_resp.json()
    assert len(videos) >= 1
    assert any(v["id"] == video_id for v in videos)

    # Delete video
    del_resp = client.delete(f"/api/v1/videos/{video_id}", headers=auth_headers)
    assert del_resp.status_code == 204

    # Verify deleted
    list_resp2 = client.get("/api/v1/videos", headers=auth_headers)
    assert not any(v["id"] == video_id for v in list_resp2.json())

def test_get_exercises(client):
    resp = client.get("/api/v1/exercises")
    assert resp.status_code == 200
    exercises = resp.json()
    assert len(exercises) >= 3
    ids = [e["id"] for e in exercises]
    assert "squat" in ids
    assert "pushup" in ids
    assert "bicep_curl" in ids

