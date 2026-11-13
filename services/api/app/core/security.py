from datetime import UTC, datetime, timedelta
from typing import Literal

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

from app.core.config import get_settings

_hasher = PasswordHasher()

TokenType = Literal["access", "refresh"]


def hash_password(plain_password: str) -> str:
    """Hash a plain password using Argon2."""
    return _hasher.hash(plain_password)


def verify_password(plain_password: str, password_hash: str) -> bool:
    """Verify a plain password against a stored Argon2 hash."""
    try:
        return _hasher.verify(password_hash, plain_password)
    except VerifyMismatchError:
        return False


def _create_token(subject: str, role: str, token_type: TokenType, expires_delta: timedelta) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    payload = {
        "sub": subject,
        "role": role,
        "type": token_type,
        "iat": now,
        "exp": now + expires_delta,
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(user_id: str, role: str) -> str:
    settings = get_settings()
    return _create_token(
        subject=user_id,
        role=role,
        token_type="access",
        expires_delta=timedelta(minutes=settings.access_token_expire_minutes),
    )


def create_refresh_token(user_id: str, role: str) -> str:
    settings = get_settings()
    return _create_token(
        subject=user_id,
        role=role,
        token_type="refresh",
        expires_delta=timedelta(days=settings.refresh_token_expire_days),
    )


def decode_token(token: str, expected_type: TokenType) -> dict | None:
    """Decode and validate JWT signature, expiration, and token type."""
    settings = get_settings()
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
        )
    except jwt.PyJWTError:
        return None

    if payload.get("type") != expected_type or not payload.get("sub"):
        return None
    return payload
