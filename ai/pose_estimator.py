import cv2
import numpy as np
from typing import List, Dict, Any, Optional

# MediaPipe landmark name mapping for convenience
LANDMARK_NAMES = {
    0: "nose",
    11: "left_shoulder", 12: "right_shoulder",
    13: "left_elbow", 14: "right_elbow",
    15: "left_wrist", 16: "right_wrist",
    23: "left_hip", 24: "right_hip",
    25: "left_knee", 26: "right_knee",
    27: "left_ankle", 28: "right_ankle",
    29: "left_heel", 30: "right_heel",
    31: "left_foot_index", 32: "right_foot_index"
}

class PoseEstimator:
    def __init__(
        self,
        min_detection_confidence: float = 0.5,
        min_tracking_confidence: float = 0.5,
        model_complexity: int = 1,
    ):
        self.min_detection_confidence = min_detection_confidence
        self.min_tracking_confidence = min_tracking_confidence
        self.model_complexity = model_complexity
        self._mp_pose = None

    def _init_model(self):
        try:
            import mediapipe as mp
            self._mp_pose = mp.solutions.pose.Pose(
                static_image_mode=False,
                model_complexity=self.model_complexity,
                smooth_landmarks=True,
                min_detection_confidence=self.min_detection_confidence,
                min_tracking_confidence=self.min_tracking_confidence,
            )
        except Exception as e:
            print(f"[PoseEstimator] MediaPipe initialization error: {e}")
            self._mp_pose = None

    def extract_landmarks_from_video(
        self, 
        video_path: str, 
        target_fps: int = 30,
        max_frames: int = 1800  # 60s @ 30fps
    ) -> Dict[str, Any]:
        """
        Reads video and extracts 33 MediaPipe pose landmarks for each frame.
        Returns:
            {
                "success": bool,
                "fps": float,
                "total_frames": int,
                "frames_landmarks": List[List[Dict[str, float]]], # frame -> 33 landmarks
                "duration_seconds": float
            }
        """
        if self._mp_pose is None:
            self._init_model()

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            return {
                "success": False,
                "error": f"Cannot open video file at {video_path}",
                "fps": 0,
                "total_frames": 0,
                "frames_landmarks": [],
                "duration_seconds": 0.0,
            }

        original_fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = frame_count / original_fps if original_fps > 0 else 0.0

        sample_interval = max(1, round(original_fps / target_fps)) if original_fps > target_fps else 1

        frames_landmarks: List[List[Dict[str, float]]] = []
        frame_idx = 0

        while cap.isOpened() and len(frames_landmarks) < max_frames:
            ret, frame = cap.read()
            if not ret:
                break

            if frame_idx % sample_interval == 0:
                # Convert BGR to RGB
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                
                if self._mp_pose:
                    results = self._mp_pose.process(rgb_frame)
                    if results.pose_landmarks:
                        landmarks = []
                        for lm in results.pose_landmarks.landmark:
                            landmarks.append({
                                "x": float(lm.x),
                                "y": float(lm.y),
                                "z": float(lm.z),
                                "visibility": float(lm.visibility),
                            })
                        frames_landmarks.append(landmarks)
                    else:
                        # Append empty landmark list if not detected in this frame
                        frames_landmarks.append([])
                else:
                    frames_landmarks.append([])

            frame_idx += 1

        cap.release()

        return {
            "success": len(frames_landmarks) > 0,
            "fps": target_fps,
            "total_frames": len(frames_landmarks),
            "frames_landmarks": frames_landmarks,
            "duration_seconds": duration,
        }
