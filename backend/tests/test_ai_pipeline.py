import math
import numpy as np
from ai.kinematics import calculate_angle_2d, calculate_vertical_angle
from ai.rules.squat_evaluator import SquatEvaluator
from ai.rules.pushup_evaluator import PushupEvaluator
from ai.rules.bicep_curl_evaluator import BicepCurlEvaluator
from ai.stgcn.graph import MediaPipePoseGraph
from ai.stgcn.model import STGCNTechniqueScorer
from ai.pipeline import ai_pipeline

def test_kinematics_angle_calculation():
    # Right angle: (0, 1) -> (0, 0) -> (1, 0)
    p1 = (0.0, 1.0)
    p2 = (0.0, 0.0)
    p3 = (1.0, 0.0)
    angle = calculate_angle_2d(p1, p2, p3)
    assert abs(angle - 90.0) < 0.01

    # Straight line: (-1, 0) -> (0, 0) -> (1, 0)
    angle_straight = calculate_angle_2d((-1.0, 0.0), (0.0, 0.0), (1.0, 0.0))
    assert abs(angle_straight - 180.0) < 0.01

def test_stgcn_graph_construction():
    graph = MediaPipePoseGraph()
    assert graph.num_node == 33
    # Check 3-partition adjacency matrix shape: (3, 33, 33)
    assert graph.A.shape == (3, 33, 33)
    assert np.all(np.isfinite(graph.A))

def test_stgcn_scorer_forward():
    scorer = STGCNTechniqueScorer()
    # Create synthetic sequence of 60 frames with 33 landmarks
    fake_frames = []
    for t in range(60):
        frame = []
        for v in range(33):
            frame.append({
                "x": 0.5 + 0.02 * math.sin(t * 0.1),
                "y": 0.5 + 0.05 * math.cos(t * 0.1),
                "z": 0.0,
                "visibility": 0.99,
            })
        fake_frames.append(frame)

    tensor = scorer.preprocess_sequence(fake_frames, target_frames=60)
    assert tensor.shape == (3, 60, 33)
    score = scorer.forward_score(tensor)
    assert 0.0 <= score <= 1.0

def test_squat_evaluator():
    evaluator = SquatEvaluator()
    # Generate 40 frames of squatting motion
    frames = []
    for t in range(40):
        # Knee bends from 160 down to 90 then back to 160
        progress = math.sin(t / 40.0 * math.pi)
        knee_y = 0.6 + progress * 0.15

        frame = [{"x": 0.5, "y": 0.5, "z": 0.0, "visibility": 0.9} for _ in range(33)]
        # Left side: hip(23), knee(25), ankle(27)
        frame[23] = {"x": 0.45, "y": 0.5, "z": 0.0, "visibility": 0.95}
        frame[25] = {"x": 0.45, "y": knee_y, "z": 0.0, "visibility": 0.95}
        frame[27] = {"x": 0.45, "y": 0.9, "z": 0.0, "visibility": 0.95}
        # Right side: hip(24), knee(26), ankle(28)
        frame[24] = {"x": 0.55, "y": 0.5, "z": 0.0, "visibility": 0.95}
        frame[26] = {"x": 0.55, "y": knee_y, "z": 0.0, "visibility": 0.95}
        frame[28] = {"x": 0.55, "y": 0.9, "z": 0.0, "visibility": 0.95}
        frames.append(frame)

    result = evaluator.evaluate(frames, fps=30.0)
    assert "score" in result
    assert "metrics" in result
    assert "errors" in result
    assert "suggestions" in result
    assert len(result["metrics"]) >= 3
