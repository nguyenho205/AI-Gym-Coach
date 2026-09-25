from typing import List
from fastapi import APIRouter, Depends, UploadFile, File, Form, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.video import VideoUploadResponse, VideoResponse
from app.services.video_service import VideoService
from app.repositories.video_repository import VideoRepository

router = APIRouter(prefix="/videos", tags=["Videos"])

@router.post("/upload", response_model=VideoUploadResponse)
async def upload_video(
    video: UploadFile = File(...),
    exercise_type: str = Form(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    video_service = VideoService(db)
    saved_video = await video_service.save_uploaded_video(
        file=video,
        user_id=current_user.id,
        exercise_type=exercise_type,
    )
    return VideoUploadResponse(
        video_id=saved_video.id,
        status="uploaded",
        file_name=saved_video.file_name,
        exercise_type=saved_video.exercise_type,
        duration_seconds=saved_video.duration_seconds,
    )

@router.get("", response_model=List[VideoResponse])
def list_videos(
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    video_repo = VideoRepository(db)
    videos = video_repo.get_by_user(current_user.id, skip=skip, limit=limit)
    return [VideoResponse.model_validate(v) for v in videos]

@router.delete("/{video_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_video(
    video_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    video_service = VideoService(db)
    video_service.delete_video(video_id, current_user.id)
    return None
