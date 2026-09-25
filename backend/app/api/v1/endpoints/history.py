from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.history import HistoryItemResponse
from app.services.analysis_service import AnalysisService

router = APIRouter(prefix="/history", tags=["History"])

@router.get("", response_model=List[HistoryItemResponse])
def get_user_history(
    exercise: Optional[str] = Query(None, description="Optional exercise filter e.g. Squat"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analysis_service = AnalysisService(db)
    return analysis_service.get_user_history(current_user.id, exercise_filter=exercise)

@router.delete("/{analysis_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_history_item(
    analysis_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analysis_service = AnalysisService(db)
    analysis_service.delete_history_item(analysis_id, current_user.id)
    return None
