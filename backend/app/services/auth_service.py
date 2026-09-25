from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.user_repository import UserRepository
from app.schemas.auth import RegisterRequest, AuthResponse
from app.schemas.user import UserCreate, UserResponse
from app.core.security import verify_password, create_access_token

class AuthService:
    def __init__(self, db: Session):
        self.user_repo = UserRepository(db)

    def register(self, req: RegisterRequest) -> AuthResponse:
        existing = self.user_repo.get_by_email(req.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email address already exists.",
            )

        user_in = UserCreate(
            email=req.email,
            full_name=req.full_name,
            password=req.password,
        )
        user = self.user_repo.create(user_in)
        token = create_access_token(user.id)

        return AuthResponse(
            success=True,
            message="Registration successful",
            access_token=token,
            user=UserResponse.model_validate(user),
        )

    def login(self, email: str, password: str) -> AuthResponse:
        user = self.user_repo.get_by_email(email)
        if not user or not verify_password(password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        token = create_access_token(user.id)
        return AuthResponse(
            success=True,
            message="Login successful",
            access_token=token,
            user=UserResponse.model_validate(user),
        )
