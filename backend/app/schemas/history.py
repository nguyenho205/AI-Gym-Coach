from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.schemas.analysis import AnalysisResultSchema

class HistoryItemResponse(BaseModel):
    id: int
    video_id: int
    exercise: str
    score: int
    rep_count: int
    status: str
    created_at: datetime
    result: Optional[AnalysisResultSchema] = None

    model_config = ConfigDict(from_attributes=True)

class HistoryListResponse(BaseModel):
    items: List[HistoryItemResponse]
    total: int
