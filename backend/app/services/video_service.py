import os
import shutil
import uuid
import cv2
from typing import Optional
from fastapi import UploadFile, HTTPException, status
from sqlalchemy.orm import Session
from app.core.config import settings
from app.repositories.video_repository import VideoRepository
from app.models.video import Video

ALLOWED_EXTENSIONS = {".mp4", ".mov", ".avi", ".mkv", ".webm"}
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100 MB

class VideoService:
    def __init__(self, db: Session):
        self.db = db
        self.video_repo = VideoRepository(db)

    def _get_video_duration(self, file_path: str) -> int:
        try:
            cap = cv2.VideoCapture(file_path)
            if not cap.isOpened():
                return 0
            fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
            frame_count = cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0
            cap.release()
            return int(frame_count / fps) if fps > 0 else 0
        except Exception:
            return 0

    async def save_uploaded_video(
        self,
        file: UploadFile,
        user_id: int,
        exercise_type: str,
    ) -> Video:
        # 1. Validate extension
        _, ext = os.path.splitext(file.filename or "")
        ext = ext.lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported video format '{ext}'. Allowed: {', '.join(ALLOWED_EXTENSIONS)}",
            )

        # 2. Generate unique filename and destination
        unique_id = uuid.uuid4().hex[:12]
        safe_filename = f"{user_id}_{exercise_type}_{unique_id}{ext}"
        destination_path = os.path.join(settings.UPLOAD_DIR, safe_filename)

        # 3. Stream save to disk & track size
        file_size = 0
        try:
            with open(destination_path, "wb") as buffer:
                while content := await file.read(1024 * 1024):  # 1MB chunks
                    file_size += len(content)
                    if file_size > MAX_FILE_SIZE:
                        buffer.close()
                        os.remove(destination_path)
                        raise HTTPException(
                            status_code=status.HTTP_400_BAD_REQUEST,
                            detail="Video file exceeds maximum size limit of 100MB.",
                        )
                    buffer.write(content)
        except Exception as e:
            if os.path.exists(destination_path):
                os.remove(destination_path)
            if isinstance(e, HTTPException):
                raise e
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save video: {str(e)}",
            )

        # 4. Extract duration
        duration_seconds = self._get_video_duration(destination_path)

        # 5. Persist record in database
        video = self.video_repo.create(
            user_id=user_id,
            file_path=destination_path,
            file_name=file.filename or safe_filename,
            file_size_bytes=file_size,
            duration_seconds=duration_seconds,
            exercise_type=exercise_type,
        )
        return video

    def delete_video(self, video_id: int, user_id: int) -> bool:
        video = self.video_repo.get_by_id(video_id)
        if not video:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Video not found.")
        if video.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

        if os.path.exists(video.file_path):
            try:
                os.remove(video.file_path)
            except Exception:
                pass

        self.video_repo.delete(video)
        return True
