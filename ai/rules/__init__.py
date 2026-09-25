from ai.rules.base_evaluator import BaseEvaluator
from ai.rules.squat_evaluator import SquatEvaluator
from ai.rules.pushup_evaluator import PushupEvaluator
from ai.rules.bicep_curl_evaluator import BicepCurlEvaluator

def get_evaluator_for_exercise(exercise_name_or_id: str) -> BaseEvaluator:
    clean = exercise_name_or_id.lower().replace("-", "").replace("_", "").replace(" ", "")
    if "squat" in clean:
        return SquatEvaluator()
    elif "push" in clean:
        return PushupEvaluator()
    elif "curl" in clean or "bicep" in clean:
        return BicepCurlEvaluator()
    else:
        # Default fallback to Squat evaluator
        return SquatEvaluator()

__all__ = ["BaseEvaluator", "SquatEvaluator", "PushupEvaluator", "BicepCurlEvaluator", "get_evaluator_for_exercise"]
