from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base

class Analysis(Base):
    __tablename__ = "analyses"

    id = Column(Integer, primary_key=True, index=True)
    video_id = Column(Integer, ForeignKey("videos.id", ondelete="CASCADE"), nullable=False, unique=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    exercise = Column(String(64), nullable=False)
    score = Column(Integer, default=0)
    rep_count = Column(Integer, default=0)
    processing_time = Column(Float, default=0.0)
    status = Column(String(32), default="completed")  # queued, processing, completed, error
    
    # Store complete structured evaluation JSON: metrics, errors, suggestions
    result_data = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    video = relationship("Video", back_populates="analysis")
    user = relationship("User", back_populates="analyses")
