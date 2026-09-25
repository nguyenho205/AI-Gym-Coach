from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate
from app.repositories.user_repository import UserRepository

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/profile", response_model=UserResponse)
def get_user_profile(current_user: User = Depends(get_current_user)):
    return UserResponse.model_validate(current_user)

@router.put("/profile", response_model=UserResponse)
def update_user_profile(
    user_in: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user_repo = UserRepository(db)
    updated = user_repo.update(current_user, user_in)
    return UserResponse.model_validate(updated)
