import os
from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "AI Gym Coach API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super_secret_ai_gym_coach_key_change_in_production_32bytes")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        f"sqlite:///{os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'ai_gym_coach.db'))}"
    )
    
    # Upload storage directory
    UPLOAD_DIR: str = os.getenv(
        "UPLOAD_DIR", 
        os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'uploads'))
    )
    
    # CORS Origins (allow Flutter Mobile, Flutter Web, localhost)
    CORS_ORIGINS: List[str] = [
        "*",
    ]

    model_config = SettingsConfigDict(case_sensitive=True)

settings = Settings()

# Ensure uploads directory exists
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
