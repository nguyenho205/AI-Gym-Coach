from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=AuthResponse)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    return auth_service.register(req)

@router.post("/login", response_model=AuthResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    return auth_service.login(req.email, req.password)
