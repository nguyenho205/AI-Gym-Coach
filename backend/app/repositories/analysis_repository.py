from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from app.models.analysis import Analysis

class AnalysisRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, analysis_id: int) -> Optional[Analysis]:
        return self.db.query(Analysis).filter(Analysis.id == analysis_id).first()

    def get_by_video_id(self, video_id: int) -> Optional[Analysis]:
        return self.db.query(Analysis).filter(Analysis.video_id == video_id).first()

    def get_user_history(
        self, 
        user_id: int, 
        exercise_filter: Optional[str] = None, 
        skip: int = 0, 
        limit: int = 50
    ) -> List[Analysis]:
        query = self.db.query(Analysis).filter(Analysis.user_id == user_id)
        if exercise_filter:
            query = query.filter(Analysis.exercise.ilike(f"%{exercise_filter}%"))
        return query.order_by(Analysis.created_at.desc()).offset(skip).limit(limit).all()

    def create(
        self,
        video_id: int,
        user_id: int,
        exercise: str,
        score: int,
        rep_count: int,
        processing_time: float,
        result_data: Dict[str, Any],
        status: str = "completed",
    ) -> Analysis:
        analysis = Analysis(
            video_id=video_id,
            user_id=user_id,
            exercise=exercise,
            score=score,
            rep_count=rep_count,
            processing_time=processing_time,
            result_data=result_data,
            status=status,
        )
        self.db.add(analysis)
        self.db.commit()
        self.db.refresh(analysis)
        return analysis

    def delete(self, analysis: Analysis) -> None:
        self.db.delete(analysis)
        self.db.commit()
