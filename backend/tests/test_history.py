import io
from unittest.mock import patch

def test_history_flow(client, auth_headers):
    # Upload video and analyze
    file_bytes = b"\x00\x00\x00\x18ftypmp42" + b"H" * 1024
    video_file = io.BytesIO(file_bytes)

    upload_resp = client.post(
        "/api/v1/videos/upload",
        files={"video": ("history_clip.mp4", video_file, "video/mp4")},
        data={"exercise_type": "pushup"},
        headers=auth_headers,
    )
    video_id = upload_resp.json()["video_id"]

    mock_eval = {
        "exercise": "Push-up",
        "score": 90,
        "rep_count": 15,
        "processing_time": 2.1,
        "is_demo_data": False,
        "metrics": [],
        "errors": [],
        "suggestions": [],
    }

    with patch("app.services.analysis_service.ai_pipeline.analyze", return_value=mock_eval):
        analyze_resp = client.post(
            "/api/v1/analysis",
            json={"video_id": video_id},
            headers=auth_headers,
        )
        analysis_id = analyze_resp.json()["analysis_id"]

        # 1. Fetch full history
        hist_resp = client.get("/api/v1/history", headers=auth_headers)
        assert hist_resp.status_code == 200
        items = hist_resp.json()
        assert len(items) >= 1
        assert any(item["id"] == analysis_id for item in items)

        # 2. Filter by matching exercise
        match_resp = client.get("/api/v1/history?exercise=Push", headers=auth_headers)
        assert match_resp.status_code == 200
        assert any(item["id"] == analysis_id for item in match_resp.json())

        # 3. Filter by non-matching exercise
        nomatch_resp = client.get("/api/v1/history?exercise=Squat", headers=auth_headers)
        assert nomatch_resp.status_code == 200
        assert not any(item["id"] == analysis_id for item in nomatch_resp.json())

        # 4. Delete history item
        del_resp = client.delete(f"/api/v1/history/{analysis_id}", headers=auth_headers)
        assert del_resp.status_code == 204

        # Verify deletion
        hist_resp2 = client.get("/api/v1/history", headers=auth_headers)
        assert not any(item["id"] == analysis_id for item in hist_resp2.json())
