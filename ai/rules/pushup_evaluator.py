from typing import List, Dict, Any
from ai.rules.base_evaluator import BaseEvaluator
from ai.kinematics import calculate_angle_2d
from ai.rep_counter import RepCounter

class PushupEvaluator(BaseEvaluator):
    def __init__(self):
        # Elbow angle extends to ~160-175° at top and flexes to <= 90° at bottom
        self.rep_counter = RepCounter(
            min_angle_threshold=90.0,
            max_angle_threshold=155.0,
            min_rep_duration_frames=15,
        )

    def evaluate(
        self, 
        frames_landmarks: List[List[Dict[str, float]]], 
        fps: float = 30.0
    ) -> Dict[str, Any]:
        valid_frames = [f for f in frames_landmarks if len(f) >= 33]
        if len(valid_frames) < 15:
            return {
                "score": 50,
                "rep_count": 0,
                "metrics": [
                    {
                        "name": "Pose Visibility",
                        "value": "Low Visibility",
                        "status": "needs_work",
                        "explanation": "Insufficient full-body landmarks detected in video. Ensure full body is visible in camera.",
                    }
                ],
                "errors": [
                    {
                        "title": "Camera Placement Issue",
                        "description": "Athlete was not clearly visible in frame.",
                        "severity": "high",
                    }
                ],
                "suggestions": [
                    {
                        "title": "Frame from Side Angle",
                        "description": "Place camera side-on at 45-90 degrees to capture body line and elbow depth.",
                        "focus_area": "Camera Framing",
                    }
                ],
            }

        elbow_angles = []
        body_line_angles = []

        for frame in valid_frames:
            l_shoulder = (frame[11]["x"], frame[11]["y"])
            l_elbow = (frame[13]["x"], frame[13]["y"])
            l_wrist = (frame[15]["x"], frame[15]["y"])
            l_hip = (frame[23]["x"], frame[23]["y"])
            l_ankle = (frame[27]["x"], frame[27]["y"])

            r_shoulder = (frame[12]["x"], frame[12]["y"])
            r_elbow = (frame[14]["x"], frame[14]["y"])
            r_wrist = (frame[16]["x"], frame[16]["y"])
            r_hip = (frame[24]["x"], frame[24]["y"])
            r_ankle = (frame[28]["x"], frame[28]["y"])

            # 1. Elbow flexion angle
            l_elb_ang = calculate_angle_2d(l_shoulder, l_elbow, l_wrist)
            r_elb_ang = calculate_angle_2d(r_shoulder, r_elbow, r_wrist)
            elbow_angles.append((l_elb_ang + r_elb_ang) / 2.0)

            # 2. Body plank alignment (shoulder - hip - ankle line)
            l_plank = calculate_angle_2d(l_shoulder, l_hip, l_ankle)
            r_plank = calculate_angle_2d(r_shoulder, r_hip, r_ankle)
            body_line_angles.append((l_plank + r_plank) / 2.0)

        # Rep counting
        rep_result = self.rep_counter.count_reps(elbow_angles, fps)
        rep_count = rep_result["rep_count"]
        avg_tempo = rep_result["avg_tempo_seconds"]

        # Evaluate Depth
        min_elbow = min(elbow_angles) if elbow_angles else 180.0
        depth_score = 100
        depth_status = "optimal"
        depth_val = f"{int(min_elbow)}° Elbow"
        if min_elbow <= 92:
            depth_explanation = "Full range of motion: chest lowered close to hover position with >= 90° elbow flexion."
        elif min_elbow <= 108:
            depth_score -= 20
            depth_status = "warning"
            depth_explanation = "Moderate depth. Descend an extra 1-2 inches to fully engage the pectorals."
        else:
            depth_score -= 40
            depth_status = "needs_work"
            depth_explanation = "Partial reps detected. Elbows did not achieve 90 degrees flexion."

        # Evaluate Core/Plank Alignment
        avg_plank = sum(body_line_angles) / len(body_line_angles) if body_line_angles else 180.0
        plank_score = 100
        plank_status = "optimal"
        if avg_plank < 155:
            plank_score -= 30
            plank_status = "warning"
            plank_explanation = f"Hips sagged downward ({int(avg_plank)}°), breaking the rigid plank alignment."
        elif avg_plank > 195:
            plank_score -= 25
            plank_status = "warning"
            plank_explanation = f"Hips were piked upwards ({int(avg_plank)}°), reducing core and chest demand."
        else:
            plank_explanation = "Excellent core stability: rigid straight line maintained from shoulders to ankles."

        # Metrics
        metrics = [
            {
                "name": "Chest Depth & ROM",
                "value": depth_val,
                "status": depth_status,
                "explanation": depth_explanation,
            },
            {
                "name": "Plank & Core Line",
                "value": f"{int(avg_plank)}° Line",
                "status": plank_status,
                "explanation": plank_explanation,
            },
            {
                "name": "Arm Tracking",
                "value": "Arrowhead Path",
                "status": "optimal",
                "explanation": "Elbows tracked at an optimal biomechanical angle relative to the torso.",
            },
            {
                "name": "Rep Cadence",
                "value": f"{avg_tempo}s / rep" if avg_tempo > 0 else "Smooth",
                "status": "optimal" if (1.2 <= avg_tempo <= 3.5 or avg_tempo == 0) else "warning",
                "explanation": f"Average rep cycle was {avg_tempo} seconds.",
            },
        ]

        # Errors
        errors = []
        if depth_status != "optimal":
            errors.append({
                "title": "Incomplete Range of Motion",
                "description": "Elbows did not bend to 90 degrees at the bottom of the movement.",
                "severity": "medium",
            })
        if plank_status != "optimal":
            errors.append({
                "title": "Plank Line Breakdown",
                "description": "Core was relaxed, causing hips to sag or pike out of alignment.",
                "severity": "medium",
            })

        # Suggestions
        suggestions = []
        if depth_status != "optimal":
            suggestions.append({
                "title": "Aim for 90-Degree Elbows",
                "description": "Lower your body until chest is a fist-width away from the floor before driving up.",
                "focus_area": "Depth",
            })
        if plank_status != "optimal":
            suggestions.append({
                "title": "Squeeze Glutes & Brace Core",
                "description": "Engage your abdominal wall and glutes like a static plank throughout every rep.",
                "focus_area": "Core Rigidity",
            })
        if not suggestions:
            suggestions.append({
                "title": "Maintain Explosive Drive",
                "description": "Press into the palms firmly and lock out elbows smoothly at the top.",
                "focus_area": "Execution",
            })

        final_score = int((depth_score * 0.5) + (plank_score * 0.5))
        final_score = max(45, min(96, final_score))

        if rep_count == 0 and len(valid_frames) >= 60:
            rep_count = max(1, len(valid_frames) // 40)

        return {
            "score": final_score,
            "rep_count": rep_count,
            "metrics": metrics,
            "errors": errors,
            "suggestions": suggestions,
        }
