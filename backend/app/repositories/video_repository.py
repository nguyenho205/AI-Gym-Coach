from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.video import Video

class VideoRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, video_id: int) -> Optional[Video]:
        return self.db.query(Video).filter(Video.id == video_id).first()

    def get_by_user(self, user_id: int, skip: int = 0, limit: int = 50) -> List[Video]:
        return (
            self.db.query(Video)
            .filter(Video.user_id == user_id)
            .order_by(Video.uploaded_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def create(
        self,
        user_id: int,
        file_path: str,
        file_name: str,
        file_size_bytes: int,
        duration_seconds: int,
        exercise_type: str,
    ) -> Video:
        video = Video(
            user_id=user_id,
            file_path=file_path,
            file_name=file_name,
            file_size_bytes=file_size_bytes,
            duration_seconds=duration_seconds,
            exercise_type=exercise_type,
        )
        self.db.add(video)
        self.db.commit()
        self.db.refresh(video)
        return video

    def delete(self, video: Video) -> None:
        self.db.delete(video)
        self.db.commit()
