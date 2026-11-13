from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.repositories.user_repo import UserRepository
from app.schemas.auth import (
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)


class AuthService:
    def __init__(self, db: Session) -> None:
        self.repo = UserRepository(db)

    def register(self, payload: RegisterRequest) -> TokenResponse:
        existing = self.repo.get_by_email(payload.email)
        if existing is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An account with this email already exists.",
            )

        user = self.repo.create(
            name=payload.name,
            email=payload.email,
            password_hash=hash_password(payload.password),
        )
        return self._issue_tokens(user)

    def login(self, payload: LoginRequest) -> TokenResponse:
        user = self.repo.get_by_email(payload.email)
        if user is None or not verify_password(payload.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )
        return self._issue_tokens(user)

    def refresh(self, payload: RefreshRequest) -> TokenResponse:
        decoded = decode_token(payload.refresh_token, expected_type="refresh")
        if decoded is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token.",
            )

        user = self.repo.get_by_id(decoded["sub"])
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User associated with token no longer exists.",
            )
        return self._issue_tokens(user)

    @staticmethod
    def _issue_tokens(user) -> TokenResponse:
        return TokenResponse(
            access_token=create_access_token(user.id, user.role),
            refresh_token=create_refresh_token(user.id, user.role),
            user=UserResponse.model_validate(user),
        )
