import io
from unittest.mock import patch

def test_analysis_endpoint_flow(client, auth_headers):
    # 1. Upload a video
    file_bytes = b"\x00\x00\x00\x18ftypmp42" + b"M" * 1024
    video_file = io.BytesIO(file_bytes)

    upload_resp = client.post(
        "/api/v1/videos/upload",
        files={"video": ("athlete_squat.mp4", video_file, "video/mp4")},
        data={"exercise_type": "squat"},
        headers=auth_headers,
    )
    assert upload_resp.status_code == 200
    video_id = upload_resp.json()["video_id"]

    # Mock the ai_pipeline.analyze output to verify contract response
    mock_eval = {
        "exercise": "Squat",
        "score": 87,
        "rep_count": 12,
        "processing_time": 1.45,
        "is_demo_data": False,
        "metrics": [
            {
                "name": "Depth & Hip Crease",
                "value": "92° Depth",
                "status": "optimal",
                "explanation": "Thighs reached parallel to the floor.",
            }
        ],
        "errors": [
            {
                "title": "Slight Knee Valgus",
                "description": "Knees drifted inwards slightly during ascent.",
                "severity": "medium",
            }
        ],
        "suggestions": [
            {
                "title": "Drive Knees Outward",
                "description": "Push knees over toes during the concentric phase.",
                "focus_area": "Knee Stability",
            }
        ],
    }

    with patch("app.services.analysis_service.ai_pipeline.analyze", return_value=mock_eval):
        # 2. Trigger analysis
        analyze_resp = client.post(
            "/api/v1/analysis",
            json={"video_id": video_id},
            headers=auth_headers,
        )
        assert analyze_resp.status_code == 200
        analysis_data = analyze_resp.json()
        assert "analysis_id" in analysis_data
        analysis_id = analysis_data["analysis_id"]
        assert analysis_data["score"] == 87
        assert analysis_data["rep_count"] == 12
        assert analysis_data["exercise"] == "Squat"
        assert analysis_data["result"]["is_demo_data"] is False
        assert len(analysis_data["result"]["metrics"]) == 1
        assert len(analysis_data["result"]["errors"]) == 1
        assert len(analysis_data["result"]["suggestions"]) == 1

        # 3. Retrieve analysis details
        detail_resp = client.get(
            f"/api/v1/analysis/{analysis_id}",
            headers=auth_headers,
        )
        assert detail_resp.status_code == 200
        detail_data = detail_resp.json()
        assert detail_data["analysis_id"] == analysis_id
        assert detail_data["score"] == 87
        assert detail_data["result"]["metrics"][0]["name"] == "Depth & Hip Crease"
