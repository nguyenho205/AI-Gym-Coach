from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class AnalysisRequest(BaseModel):
    video_id: int

class TechniqueMetricSchema(BaseModel):
    name: str
    value: str
    status: str = "optimal"  # optimal, warning, needs_work
    explanation: str

class TechniqueErrorSchema(BaseModel):
    title: str
    description: str
    severity: str = "medium"  # low, medium, high

class SuggestionSchema(BaseModel):
    title: str
    description: str
    focus_area: Optional[str] = None

class AnalysisResultSchema(BaseModel):
    exercise: str
    score: int
    rep_count: int
    processing_time: float
    is_demo_data: bool = False
    metrics: List[TechniqueMetricSchema] = []
    errors: List[TechniqueErrorSchema] = []
    suggestions: List[SuggestionSchema] = []

class AnalysisResponse(BaseModel):
    analysis_id: int
    status: str = "completed"
    video_id: int
    exercise: str
    score: int
    rep_count: int
    created_at: datetime
    result: Optional[AnalysisResultSchema] = None

    model_config = ConfigDict(from_attributes=True)
