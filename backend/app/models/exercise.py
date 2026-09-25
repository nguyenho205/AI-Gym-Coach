from sqlalchemy import Column, String
from app.core.database import Base

class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(String(64), primary_key=True, index=True)  # e.g. "squat", "pushup", "bicep_curl"
    name = Column(String(128), nullable=False)
    short_description = Column(String(512), nullable=False)
    technique_focus = Column(String(256), nullable=False)
    category = Column(String(64), default="Strength")
