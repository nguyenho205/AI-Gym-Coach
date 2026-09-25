from typing import Optional
from pydantic import BaseModel, EmailStr
from app.schemas.user import UserResponse

class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "Bearer"

class AuthResponse(BaseModel):
    success: bool
    message: str
    access_token: Optional[str] = None
    user: Optional[UserResponse] = None
