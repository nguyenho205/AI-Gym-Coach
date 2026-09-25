from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.exercise import Exercise
from app.schemas.exercise import ExerciseResponse

router = APIRouter(prefix="/exercises", tags=["Exercises"])

DEFAULT_EXERCISES = [
    {
        "id": "squat",
        "name": "Squat",
        "short_description": "Analyze squat depth, knee alignment, and posture.",
        "technique_focus": "Depth & Knee Valgus",
        "category": "Legs",
    },
    {
        "id": "pushup",
        "name": "Push-up",
        "short_description": "Analyze body alignment, chest depth, and elbow movement.",
        "technique_focus": "Elbow Flare & Core Alignment",
        "category": "Chest",
    },
    {
        "id": "bicep_curl",
        "name": "Bicep Curl",
        "short_description": "Analyze elbow stability, range of motion, and movement control.",
        "technique_focus": "Elbow Stability & Torso Momentum",
        "category": "Arms",
    },
]

@router.get("", response_model=List[ExerciseResponse])
def get_exercises(db: Session = Depends(get_db)):
    """Returns list of supported exercises from the database, auto-seeding if empty."""
    exercises = db.query(Exercise).all()
    if not exercises:
        for ex_data in DEFAULT_EXERCISES:
            db.add(Exercise(**ex_data))
        db.commit()
        exercises = db.query(Exercise).all()
    return exercises
