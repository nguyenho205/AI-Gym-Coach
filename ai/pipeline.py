import time
from typing import Dict, Any
from ai.pose_estimator import PoseEstimator
from ai.rules import get_evaluator_for_exercise
from ai.stgcn.model import STGCNTechniqueScorer

class AIPipeline:
    def __init__(self):
        self.pose_estimator = PoseEstimator()
        self.stgcn_scorer = STGCNTechniqueScorer()

    def analyze(self, video_path: str, exercise_type: str) -> Dict[str, Any]:
        start_time = time.time()

        # 1. Pose estimation: extract 33 landmarks per frame
        extraction_result = self.pose_estimator.extract_landmarks_from_video(
            video_path=video_path,
            target_fps=30,
        )
        frames_landmarks = extraction_result.get("frames_landmarks", [])
        fps = extraction_result.get("fps", 30.0)

        # 2. Rule-based evaluation (angles, biomechanics, rep count)
        evaluator = get_evaluator_for_exercise(exercise_type)
        rule_result = evaluator.evaluate(frames_landmarks, fps=fps)

        # 3. ST-GCN Spatio-Temporal evaluation
        tensor = self.stgcn_scorer.preprocess_sequence(frames_landmarks, target_frames=60)
        stgcn_fluency = self.stgcn_scorer.forward_score(tensor)

        # Blend rule score (70%) and ST-GCN temporal fluency (30%)
        rule_score = rule_result["score"]
        blended_score = int((rule_score * 0.70) + (stgcn_fluency * 100 * 0.30))
        blended_score = max(45, min(98, blended_score))

        elapsed_time = round(time.time() - start_time, 2)

        return {
            "exercise": exercise_type.capitalize().replace("_", " "),
            "score": blended_score,
            "rep_count": rule_result["rep_count"],
            "processing_time": elapsed_time,
            "is_demo_data": False,  # Real AI processing pipeline result!
            "metrics": rule_result["metrics"],
            "errors": rule_result["errors"],
            "suggestions": rule_result["suggestions"],
        }

# Global singleton pipeline instance
ai_pipeline = AIPipeline()
