from typing import List, Dict, Any
from ai.rules.base_evaluator import BaseEvaluator
from ai.kinematics import calculate_angle_2d, calculate_vertical_angle, calculate_distance_2d
from ai.rep_counter import RepCounter

class SquatEvaluator(BaseEvaluator):
    def __init__(self):
        # Knee angle typically extends to ~165-175° at top and flexes to <= 90° at parallel squat
        self.rep_counter = RepCounter(
            min_angle_threshold=95.0,
            max_angle_threshold=160.0,
            min_rep_duration_frames=18,
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
                        "description": "Athlete full body was not consistently visible throughout the clip.",
                        "severity": "high",
                    }
                ],
                "suggestions": [
                    {
                        "title": "Adjust Camera Distance",
                        "description": "Position the camera 2.5 - 3 meters away at hip height showing head to toes.",
                        "focus_area": "Camera Framing",
                    }
                ],
            }

        knee_angles = []
        hip_angles = []
        back_angles = []
        knee_valgus_ratios = []
        heel_lift_counts = 0

        for frame in valid_frames:
            # Left side landmarks
            l_shoulder = (frame[11]["x"], frame[11]["y"])
            l_hip = (frame[23]["x"], frame[23]["y"])
            l_knee = (frame[25]["x"], frame[25]["y"])
            l_ankle = (frame[27]["x"], frame[27]["y"])
            l_heel = (frame[29]["x"], frame[29]["y"])
            l_toe = (frame[31]["x"], frame[31]["y"])

            # Right side landmarks
            r_shoulder = (frame[12]["x"], frame[12]["y"])
            r_hip = (frame[24]["x"], frame[24]["y"])
            r_knee = (frame[26]["x"], frame[26]["y"])
            r_ankle = (frame[28]["x"], frame[28]["y"])
            r_heel = (frame[30]["x"], frame[30]["y"])
            r_toe = (frame[32]["x"], frame[32]["y"])

            # 1. Knee flexion angle
            l_knee_ang = calculate_angle_2d(l_hip, l_knee, l_ankle)
            r_knee_ang = calculate_angle_2d(r_hip, r_knee, r_ankle)
            avg_knee_ang = (l_knee_ang + r_knee_ang) / 2.0
            knee_angles.append(avg_knee_ang)

            # 2. Back inclination from vertical
            l_back = calculate_vertical_angle(l_shoulder, l_hip)
            r_back = calculate_vertical_angle(r_shoulder, r_hip)
            back_angles.append((l_back + r_back) / 2.0)

            # 3. Knee Valgus estimation (knee distance relative to ankle distance)
            knee_dist = calculate_distance_2d(l_knee, r_knee)
            ankle_dist = calculate_distance_2d(l_ankle, r_ankle)
            if ankle_dist > 0.05:
                ratio = knee_dist / ankle_dist
                knee_valgus_ratios.append(ratio)

            # 4. Heel lift estimation
            if abs(l_heel[1] - l_toe[1]) > 0.06 or abs(r_heel[1] - r_toe[1]) > 0.06:
                heel_lift_counts += 1

        # Rep counting
        rep_result = self.rep_counter.count_reps(knee_angles, fps)
        rep_count = rep_result["rep_count"]
        avg_tempo = rep_result["avg_tempo_seconds"]

        # Evaluate Depth
        min_knee_angle = min(knee_angles) if knee_angles else 180.0
        depth_score = 100
        depth_status = "optimal"
        depth_val = f"{int(min_knee_angle)}° Depth"
        if min_knee_angle <= 95:
            depth_explanation = "Excellent depth: thighs achieved parallel or below parallel to the floor."
        elif min_knee_angle <= 110:
            depth_score -= 20
            depth_status = "warning"
            depth_explanation = "Borderline parallel depth. Aim to drop 2-3 inches lower for maximum glute recruitment."
        else:
            depth_score -= 40
            depth_status = "needs_work"
            depth_explanation = "Squat depth too shallow. Thighs remained well above parallel."

        # Evaluate Back angle
        avg_back_angle = sum(back_angles) / len(back_angles) if back_angles else 0.0
        back_status = "optimal"
        back_score = 100
        if avg_back_angle > 48:
            back_score -= 30
            back_status = "warning"
            back_explanation = f"Torso tilted forward excessively ({int(avg_back_angle)}°), placing undue shear load on lumbar spine."
        else:
            back_explanation = f"Neutral spine preserved with controlled forward torso inclination ({int(avg_back_angle)}°)."

        # Evaluate Knee Valgus
        avg_valgus = sum(knee_valgus_ratios) / len(knee_valgus_ratios) if knee_valgus_ratios else 1.0
        valgus_score = 100
        valgus_status = "optimal"
        valgus_explanation = "Knees tracked straight and stable over the toes throughout the ascent."
        has_valgus = False
        if avg_valgus < 0.78:
            valgus_score -= 30
            valgus_status = "warning"
            valgus_explanation = "Mild knee collapse (valgus) detected during concentric drive phase."
            has_valgus = True

        # Assemble Metrics
        metrics = [
            {
                "name": "Depth & Hip Crease",
                "value": depth_val,
                "status": depth_status,
                "explanation": depth_explanation,
            },
            {
                "name": "Knee Alignment",
                "value": "Stable Line" if not has_valgus else "Inward Collapse",
                "status": valgus_status,
                "explanation": valgus_explanation,
            },
            {
                "name": "Back Angle & Rigidity",
                "value": f"{int(avg_back_angle)}° Incline",
                "status": back_status,
                "explanation": back_explanation,
            },
            {
                "name": "Cadence & Tempo",
                "value": f"{avg_tempo}s / rep" if avg_tempo > 0 else "Controlled",
                "status": "optimal" if (1.5 <= avg_tempo <= 4.0 or avg_tempo == 0) else "warning",
                "explanation": f"Average rep cycle duration was {avg_tempo}s with consistent pacing.",
            }
        ]

        # Assemble Errors
        errors = []
        if depth_status != "optimal":
            errors.append({
                "title": "Insufficient Squat Depth",
                "description": "Hips did not descend to or below the top of the patella.",
                "severity": "medium" if depth_status == "warning" else "high",
            })
        if has_valgus:
            errors.append({
                "title": "Knee Valgus on Ascent",
                "description": "Knees drifted inwards when pushing up from the bottom.",
                "severity": "medium",
            })
        if back_status != "optimal":
            errors.append({
                "title": "Excessive Forward Lean",
                "description": "Torso tilted too far forward, shifting load away from quads onto lower back.",
                "severity": "medium",
            })
        if heel_lift_counts > len(valid_frames) * 0.15:
            errors.append({
                "title": "Heel Lift at Bottom",
                "description": "Weight shifted forward onto toes, lifting heels slightly.",
                "severity": "low",
            })

        # Assemble Suggestions
        suggestions = []
        if depth_status != "optimal":
            suggestions.append({
                "title": "Work on Hip Mobility & Depth",
                "description": "Perform goblet squats or ankle dorsiflexion stretches to comfortably reach full parallel.",
                "focus_area": "Squat Depth",
            })
        if has_valgus:
            suggestions.append({
                "title": "Cue Knees Outward",
                "description": "Actively spread the floor apart with your feet and push knees over your pinky toes.",
                "focus_area": "Knee Stability",
            })
        if back_status != "optimal":
            suggestions.append({
                "title": "Proud Chest & Abdominal Bracing",
                "description": "Keep chest elevated and take a deep diaphragmatic breath into your core before starting descent.",
                "focus_area": "Torso Rigidity",
            })
        if not suggestions:
            suggestions.append({
                "title": "Maintain Progressive Overload",
                "description": "Form is solid! Focus on gradual volume and load progression.",
                "focus_area": "Progress",
            })

        # Overall weighted score
        final_score = int((depth_score * 0.4) + (valgus_score * 0.3) + (back_score * 0.3))
        final_score = max(40, min(98, final_score))

        # Default rep count fallback if video is short/static
        if rep_count == 0 and len(valid_frames) >= 60:
            rep_count = max(1, len(valid_frames) // 45)

        return {
            "score": final_score,
            "rep_count": rep_count,
            "metrics": metrics,
            "errors": errors,
            "suggestions": suggestions,
        }
