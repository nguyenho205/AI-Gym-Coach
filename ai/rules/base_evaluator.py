from abc import ABC, abstractmethod
from typing import List, Dict, Any

class BaseEvaluator(ABC):
    @abstractmethod
    def evaluate(
        self, 
        frames_landmarks: List[List[Dict[str, float]]], 
        fps: float = 30.0
    ) -> Dict[str, Any]:
        """
        Evaluates technique from sequence of 33 body landmarks.
        Returns:
            {
                "score": int,
                "rep_count": int,
                "metrics": List[Dict[str, str]], # name, value, status, explanation
                "errors": List[Dict[str, str]],  # title, description, severity
                "suggestions": List[Dict[str, str]], # title, description, focus_area
            }
        """
        pass
