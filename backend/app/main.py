import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.core.config import settings
from app.core.database import engine, Base, SessionLocal
from app.models.exercise import Exercise
from app.api.v1.api_router import api_router

def init_db():
    """Initializes tables and seeds default exercises."""
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # Seed supported exercises if not already present
        defaults = [
            Exercise(
                id="squat",
                name="Squat",
                short_description="Analyze squat depth, knee alignment, and posture.",
                technique_focus="Depth & Knee Valgus",
                category="Legs",
            ),
            Exercise(
                id="pushup",
                name="Push-up",
                short_description="Analyze body alignment, chest depth, and elbow movement.",
                technique_focus="Elbow Flare & Core Alignment",
                category="Chest",
            ),
            Exercise(
                id="bicep_curl",
                name="Bicep Curl",
                short_description="Analyze elbow stability, range of motion, and movement control.",
                technique_focus="Elbow Stability & Torso Momentum",
                category="Arms",
            ),
        ]
        for ex in defaults:
            if not db.query(Exercise).filter(Exercise.id == ex.id).first():
                db.add(ex)
        db.commit()
    finally:
        db.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialize database
    init_db()
    yield
    # Shutdown logic if needed

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API and AI Video Biomechanical Analysis Service for AI-Coach-Gym",
    lifespan=lifespan,
)

# CORS Middleware (allows Flutter mobile app on physical devices, emulators, and local web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount uploaded media directory for video playback / streaming
if os.path.exists(settings.UPLOAD_DIR):
    app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

# Include API v1 Router
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/", tags=["Health"])
def root():
    return {
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "online",
        "docs_url": "/docs",
        "api_v1": settings.API_V1_STR,
    }

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy"}
