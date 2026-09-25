from datetime import datetime
from pydantic import BaseModel, ConfigDict

class VideoUploadResponse(BaseModel):
    video_id: int
    status: str
    file_name: str
    exercise_type: str
    duration_seconds: int

class VideoResponse(BaseModel):
    id: int
    user_id: int
    file_name: str
    file_size_bytes: int
    duration_seconds: int
    exercise_type: str
    uploaded_at: datetime

    model_config = ConfigDict(from_attributes=True)
