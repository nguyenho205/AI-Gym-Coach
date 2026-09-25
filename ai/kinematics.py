import math
from typing import Tuple, Dict, Any, List

def calculate_angle_2d(p1: Tuple[float, float], p2: Tuple[float, float], p3: Tuple[float, float]) -> float:
    """
    Calculates the internal angle at vertex p2 formed by (p1 - p2) and (p3 - p2) in degrees.
    Points are (x, y) coordinates.
    """
    x1, y1 = p1
    x2, y2 = p2
    x3, y3 = p3

    # Vectors
    v1x = x1 - x2
    v1y = y1 - y2
    v2x = x3 - x2
    v2y = y3 - y2

    dot_product = v1x * v2x + v1y * v2y
    mag1 = math.sqrt(v1x**2 + v1y**2)
    mag2 = math.sqrt(v2x**2 + v2y**2)

    if mag1 * mag2 == 0:
        return 0.0

    cos_angle = dot_product / (mag1 * mag2)
    # Clamp to avoid numerical floating-point errors outside [-1, 1]
    cos_angle = max(-1.0, min(1.0, cos_angle))
    angle = math.degrees(math.acos(cos_angle))
    return angle

def calculate_distance_2d(p1: Tuple[float, float], p2: Tuple[float, float]) -> float:
    """Calculates Euclidean distance between two 2D points."""
    return math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)

def calculate_vertical_angle(top_point: Tuple[float, float], bottom_point: Tuple[float, float]) -> float:
    """
    Calculates angle of inclination from the vertical axis.
    0 degrees means perfectly upright/vertical.
    """
    dx = top_point[0] - bottom_point[0]
    dy = bottom_point[1] - top_point[1]  # Inverted Y in image coordinates
    return abs(math.degrees(math.atan2(dx, dy)))

def smooth_trajectory(values: List[float], window_size: int = 5) -> List[float]:
    """Applies moving average smoothing to joint angle trajectory."""
    if len(values) < window_size:
        return values
    smoothed = []
    half = window_size // 2
    for i in range(len(values)):
        start = max(0, i - half)
        end = min(len(values), i + half + 1)
        sub = values[start:end]
        smoothed.append(sum(sub) / len(sub))
    return smoothed
