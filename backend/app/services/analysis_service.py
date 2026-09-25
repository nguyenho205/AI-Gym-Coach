import os
import sys
from typing import Optional, List
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

# Add project root to sys.path so we can import ai package cleanly
root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
if root_path not in sys.path:
    sys.path.insert(0, root_path)

from ai.pipeline import ai_pipeline
from app.repositories.video_repository import VideoRepository
from app.repositories.analysis_repository import AnalysisRepository
from app.models.analysis import Analysis
from app.schemas.analysis import AnalysisResponse, AnalysisResultSchema
from app.schemas.history import HistoryItemResponse

class AnalysisService:
    def __init__(self, db: Session):
        self.db = db
        self.video_repo = VideoRepository(db)
        self.analysis_repo = AnalysisRepository(db)

    def analyze_video(self, video_id: int, user_id: int) -> Analysis:
        video = self.video_repo.get_by_id(video_id)
        if not video:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Video with id {video_id} does not exist.",
            )

        if video.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to analyze this video.",
            )

        # Check if already analyzed
        existing = self.analysis_repo.get_by_video_id(video_id)
        if existing:
            return existing

        # Execute AI analysis pipeline
        if not os.path.exists(video.file_path):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Video file missing on server storage.",
            )

        try:
            eval_result = ai_pipeline.analyze(
                video_path=video.file_path,
                exercise_type=video.exercise_type,
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"AI pipeline analysis encountered an error: {str(e)}",
            )

        # Save to database
        analysis = self.analysis_repo.create(
            video_id=video.id,
            user_id=user_id,
            exercise=eval_result["exercise"],
            score=eval_result["score"],
            rep_count=eval_result["rep_count"],
            processing_time=eval_result["processing_time"],
            result_data=eval_result,
            status="completed",
        )
        return analysis

    def get_analysis_by_id(self, analysis_id: int, user_id: int) -> Analysis:
        analysis = self.analysis_repo.get_by_id(analysis_id)
        if not analysis:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Analysis report {analysis_id} not found.",
            )
        if analysis.user_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to this report.",
            )
        return analysis

    def get_user_history(
        self, 
        user_id: int, 
        exercise_filter: Optional[str] = None
    ) -> List[HistoryItemResponse]:
        analyses = self.analysis_repo.get_user_history(user_id, exercise_filter)
        results = []
        for a in analyses:
            result_schema = None
            if a.result_data:
                try:
                    result_schema = AnalysisResultSchema.model_validate(a.result_data)
                except Exception:
                    pass

            results.append(HistoryItemResponse(
                id=a.id,
                video_id=a.video_id,
                exercise=a.exercise,
                score=a.score,
                rep_count=a.rep_count,
                status=a.status,
                created_at=a.created_at,
                result=result_schema,
            ))
        return results

    def delete_history_item(self, analysis_id: int, user_id: int) -> bool:
        analysis = self.get_analysis_by_id(analysis_id, user_id)
        self.analysis_repo.delete(analysis)
        return True
