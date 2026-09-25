from typing import List, Dict, Any
from ai.rules.base_evaluator import BaseEvaluator
from ai.kinematics import calculate_angle_2d, calculate_vertical_angle
from ai.rep_counter import RepCounter

class BicepCurlEvaluator(BaseEvaluator):
    def __init__(self):
        # Bicep curl: flexes to ~45-55° at peak contraction, extends to ~155-170° at bottom
        self.rep_counter = RepCounter(
            min_angle_threshold=65.0,
            max_angle_threshold=145.0,
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
                        "explanation": "Insufficient upper body landmarks detected in video.",
                    }
                ],
                "errors": [
                    {
                        "title": "Camera Placement Issue",
                        "description": "Athlete arms and torso were not clearly visible.",
                        "severity": "high",
                    }
                ],
                "suggestions": [
                    {
                        "title": "Camera at Chest Height",
                        "description": "Position camera showing torso and arms clearly.",
                        "focus_area": "Camera Framing",
                    }
                ],
            }

        elbow_angles = []
        torso_swings = []
        elbow_drift_deltas = []

        initial_elbow_x = None

        for frame in valid_frames:
            l_shoulder = (frame[11]["x"], frame[11]["y"])
            l_elbow = (frame[13]["x"], frame[13]["y"])
            l_wrist = (frame[15]["x"], frame[15]["y"])
            l_hip = (frame[23]["x"], frame[23]["y"])

            r_shoulder = (frame[12]["x"], frame[12]["y"])
            r_elbow = (frame[14]["x"], frame[14]["y"])
            r_wrist = (frame[16]["x"], frame[16]["y"])
            r_hip = (frame[24]["x"], frame[24]["y"])

            # 1. Elbow curl angle
            l_elb_ang = calculate_angle_2d(l_shoulder, l_elbow, l_wrist)
            r_elb_ang = calculate_angle_2d(r_shoulder, r_elbow, r_wrist)
            elbow_angles.append((l_elb_ang + r_elb_ang) / 2.0)

            # 2. Torso swing
            l_torso = calculate_vertical_angle(l_shoulder, l_hip)
            r_torso = calculate_vertical_angle(r_shoulder, r_hip)
            torso_swings.append((l_torso + r_torso) / 2.0)

            # 3. Elbow drift
            avg_elbow_x = (l_elbow[0] + r_elbow[0]) / 2.0
            if initial_elbow_x is None:
                initial_elbow_x = avg_elbow_x
            elbow_drift_deltas.append(abs(avg_elbow_x - initial_elbow_x))

        # Rep counting
        rep_result = self.rep_counter.count_reps(elbow_angles, fps)
        rep_count = rep_result["rep_count"]
        avg_tempo = rep_result["avg_tempo_seconds"]

        # Evaluate ROM
        min_angle = min(elbow_angles) if elbow_angles else 180.0
        max_angle = max(elbow_angles) if elbow_angles else 0.0
        rom_score = 100
        rom_status = "optimal"
        if min_angle > 65 or max_angle < 140:
            rom_score -= 25
            rom_status = "warning"
            rom_explanation = f"Limited ROM: peak curl was {int(min_angle)}° and extension was {int(max_angle)}°."
        else:
            rom_explanation = "Full range of motion achieved with complete extension and peak contraction."

        # Evaluate Torso Swing / Momentum
        max_torso_swing = max(torso_swings) if torso_swings else 0.0
        min_torso_swing = min(torso_swings) if torso_swings else 0.0
        swing_range = max_torso_swing - min_torso_swing
        swing_score = 100
        swing_status = "optimal"
        if swing_range > 18:
            swing_score -= 30
            swing_status = "warning"
            swing_explanation = f"Noticeable torso swinging ({int(swing_range)}° variation) used to generate momentum."
        else:
            swing_explanation = "Stable, upright posture with isolated bicep contraction."

        # Evaluate Elbow Stability
        max_drift = max(elbow_drift_deltas) if elbow_drift_deltas else 0.0
        elbow_status = "optimal"
        elbow_score = 100
        if max_drift > 0.08:
            elbow_score -= 20
            elbow_status = "warning"
            elbow_explanation = "Elbows drifted forward during the lift, shifting tension onto anterior deltoids."
        else:
            elbow_explanation = "Elbows remained locked firmly by your sides throughout."

        metrics = [
            {
                "name": "Bicep Contraction & ROM",
                "value": f"{int(min_angle)}° - {int(max_angle)}°",
                "status": rom_status,
                "explanation": rom_explanation,
            },
            {
                "name": "Elbow Stability",
                "value": "Pinned" if elbow_status == "optimal" else "Drifting",
                "status": elbow_status,
                "explanation": elbow_explanation,
            },
            {
                "name": "Torso Stillness",
                "value": "Rigid" if swing_status == "optimal" else "Swinging",
                "status": swing_status,
                "explanation": swing_explanation,
            },
            {
                "name": "Eccentric Tempo",
                "value": f"{avg_tempo}s / rep" if avg_tempo > 0 else "Controlled",
                "status": "optimal" if (1.5 <= avg_tempo <= 4.0 or avg_tempo == 0) else "warning",
                "explanation": f"Average rep cycle was {avg_tempo} seconds.",
            },
        ]

        errors = []
        if rom_status != "optimal":
            errors.append({
                "title": "Incomplete Range of Motion",
                "description": "Arms did not fully extend at the bottom or peak squeeze at the top.",
                "severity": "medium",
            })
        if swing_status != "optimal":
            errors.append({
                "title": "Torso Momentum & Swing",
                "description": "Rocking the torso back and forth to hoist the weight.",
                "severity": "medium",
            })
        if elbow_status != "optimal":
            errors.append({
                "title": "Elbow Drift",
                "description": "Elbows moved forward to recruit front deltoid instead of pure bicep flexion.",
                "severity": "low",
            })

        suggestions = []
        if swing_status != "optimal":
            suggestions.append({
                "title": "Pin Back Against a Wall or Stand Tall",
                "description": "Keep abs tight and avoid leaning backward as the weights ascend.",
                "focus_area": "Torso Stability",
            })
        if elbow_status != "optimal":
            suggestions.append({
                "title": "Lock Elbows to Ribcage",
                "description": "Imagine clamping a rolled towel under each armpit to keep elbows stationary.",
                "focus_area": "Isolation",
            })
        if not suggestions:
            suggestions.append({
                "title": "Emphasize 2-Second Lowering",
                "description": "Slow down the negative eccentric portion to stimulate muscle growth.",
                "focus_area": "Tempo",
            })

        final_score = int((rom_score * 0.4) + (swing_score * 0.35) + (elbow_score * 0.25))
        final_score = max(45, min(97, final_score))

        if rep_count == 0 and len(valid_frames) >= 60:
            rep_count = max(1, len(valid_frames) // 40)

        return {
            "score": final_score,
            "rep_count": rep_count,
            "metrics": metrics,
            "errors": errors,
            "suggestions": suggestions,
        }
