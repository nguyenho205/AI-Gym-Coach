from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, videos, analysis, history, exercises

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(videos.router)
api_router.include_router(analysis.router)
api_router.include_router(history.router)
api_router.include_router(exercises.router)

