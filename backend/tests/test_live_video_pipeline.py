import os
import cv2
import numpy as np
from ai.pipeline import ai_pipeline

def test_pipeline_on_real_video_file(tmp_path):
    # 1. Create a dummy 1-second 30fps MP4 video with OpenCV
    video_file_path = str(tmp_path / "test_exercise.mp4")
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    out = cv2.VideoWriter(video_file_path, fourcc, 30.0, (640, 480))

    for i in range(30):
        # Draw a synthetic human stick figure moving up and down
        frame = np.ones((480, 640, 3), dtype=np.uint8) * 255
        # Head
        cv2.circle(frame, (320, 100 + (i % 5)), 25, (50, 50, 50), -1)
        # Torso
        cv2.line(frame, (320, 125), (320, 260), (50, 50, 50), 8)
        # Arms
        cv2.line(frame, (320, 160), (250, 200), (50, 50, 50), 6)
        cv2.line(frame, (320, 160), (390, 200), (50, 50, 50), 6)
        # Legs
        cv2.line(frame, (320, 260), (270, 380), (50, 50, 50), 8)
        cv2.line(frame, (320, 260), (370, 380), (50, 50, 50), 8)
        out.write(frame)

    out.release()
    assert os.path.exists(video_file_path)

    # 2. Run real AI pipeline
    result = ai_pipeline.analyze(video_file_path, "squat")
    assert result is not None
    assert "exercise" in result
    assert "score" in result
    assert "rep_count" in result
    assert "metrics" in result
    assert "errors" in result
    assert "suggestions" in result
    assert result["is_demo_data"] is False
    assert result["processing_time"] >= 0.0
