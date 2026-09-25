from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.analysis import AnalysisRequest, AnalysisResponse, AnalysisResultSchema
from app.services.analysis_service import AnalysisService

router = APIRouter(prefix="/analysis", tags=["Analysis"])

@router.post("", response_model=AnalysisResponse)
def analyze_video(
    req: AnalysisRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analysis_service = AnalysisService(db)
    analysis = analysis_service.analyze_video(req.video_id, current_user.id)
    
    result_schema = None
    if analysis.result_data:
        try:
            result_schema = AnalysisResultSchema.model_validate(analysis.result_data)
        except Exception:
            pass

    return AnalysisResponse(
        analysis_id=analysis.id,
        status=analysis.status,
        video_id=analysis.video_id,
        exercise=analysis.exercise,
        score=analysis.score,
        rep_count=analysis.rep_count,
        created_at=analysis.created_at,
        result=result_schema,
    )

@router.get("/{analysis_id}", response_model=AnalysisResponse)
def get_analysis_detail(
    analysis_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analysis_service = AnalysisService(db)
    analysis = analysis_service.get_analysis_by_id(analysis_id, current_user.id)

    result_schema = None
    if analysis.result_data:
        try:
            result_schema = AnalysisResultSchema.model_validate(analysis.result_data)
        except Exception:
            pass

    return AnalysisResponse(
        analysis_id=analysis.id,
        status=analysis.status,
        video_id=analysis.video_id,
        exercise=analysis.exercise,
        score=analysis.score,
        rep_count=analysis.rep_count,
        created_at=analysis.created_at,
        result=result_schema,
    )
