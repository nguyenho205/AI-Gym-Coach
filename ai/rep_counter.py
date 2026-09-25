from typing import List, Tuple, Dict, Any
from ai.kinematics import smooth_trajectory

class RepCounter:
    """
    Identifies repetition boundaries by tracking primary joint angle troughs and peaks.
    """
    def __init__(
        self,
        min_angle_threshold: float,
        max_angle_threshold: float,
        min_rep_duration_frames: int = 15,
    ):
        self.min_angle = min_angle_threshold
        self.max_angle = max_angle_threshold
        self.min_rep_frames = min_rep_duration_frames

    def count_reps(
        self, 
        angles: List[float], 
        fps: float = 30.0
    ) -> Dict[str, Any]:
        """
        Analyzes angle trajectory over frames.
        Returns:
            {
                "rep_count": int,
                "rep_segments": List[Tuple[int, int]], # (start_frame, end_frame)
                "avg_tempo_seconds": float,
            }
        """
        if not angles or len(angles) < self.min_rep_frames:
            return {"rep_count": 0, "rep_segments": [], "avg_tempo_seconds": 0.0}

        smoothed = smooth_trajectory(angles, window_size=5)

        # State machine for rep detection:
        # State: 0 = at top/extended, 1 = flexing (eccentric), 2 = at bottom/inflection, 3 = extending (concentric)
        state = 0
        rep_count = 0
        rep_segments = []
        current_rep_start = 0

        for idx, angle in enumerate(smoothed):
            if state == 0:
                # Waiting to initiate movement downward
                if angle < self.max_angle - 15:
                    state = 1
                    current_rep_start = idx
            elif state == 1:
                # Descending toward bottom
                if angle <= self.min_angle + 10:
                    state = 2
            elif state == 2:
                # Bottom position reached, ascending
                if angle > self.min_angle + 20:
                    state = 3
            elif state == 3:
                # Ascending back to start/lockout
                if angle >= self.max_angle - 15:
                    rep_duration = idx - current_rep_start
                    if rep_duration >= self.min_rep_frames:
                        rep_count += 1
                        rep_segments.append((current_rep_start, idx))
                    state = 0

        avg_tempo = 0.0
        if rep_segments:
            total_frames = sum(end - start for start, end in rep_segments)
            avg_tempo = (total_frames / len(rep_segments)) / (fps if fps > 0 else 30.0)

        return {
            "rep_count": rep_count,
            "rep_segments": rep_segments,
            "avg_tempo_seconds": round(avg_tempo, 2),
        }
