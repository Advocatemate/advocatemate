from __future__ import annotations

import hashlib
import hmac
import secrets
import uuid
from datetime import UTC, datetime, timedelta

import jwt

from app.core.config import get_settings
from app.core.errors import Unauthorized


def create_access_token(*, user_id: uuid.UUID, session_id: uuid.UUID, role: str) -> tuple[str, int]:
    s = get_settings()
    now = datetime.now(UTC)
    ttl = s.access_token_ttl_minutes * 60
    payload = {
        "sub": str(user_id),
        "sid": str(session_id),
        "role": role,
        "iss": s.jwt_issuer,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(seconds=ttl)).timestamp()),
        "typ": "access",
        "jti": secrets.token_hex(8),
    }
    return jwt.encode(payload, s.jwt_secret, algorithm=s.jwt_algorithm), ttl


def decode_access_token(token: str) -> dict:
    s = get_settings()
    try:
        claims = jwt.decode(
            token,
            s.jwt_secret,
            algorithms=[s.jwt_algorithm],
            issuer=s.jwt_issuer,
            options={"require": ["exp", "sub", "sid", "iss"]},
        )
    except jwt.ExpiredSignatureError as e:
        raise Unauthorized("Access token expired", code="token_expired") from e
    except jwt.PyJWTError as e:
        raise Unauthorized("Invalid access token", code="invalid_token") from e
    if claims.get("typ") != "access":
        raise Unauthorized("Invalid access token", code="invalid_token")
    return claims


def new_refresh_token() -> str:
    return secrets.token_urlsafe(48)


def hash_token(token: str) -> str:
    """Refresh tokens are stored only as keyed hashes."""
    return hmac.new(get_settings().jwt_secret.encode(), token.encode(), hashlib.sha256).hexdigest()


def generate_otp(length: int) -> str:
    return "".join(secrets.choice("0123456789") for _ in range(length))


def hash_otp(phone: str, code: str, salt: str) -> str:
    key = get_settings().otp_hash_secret.encode()
    return hmac.new(key, f"{phone}:{salt}:{code}".encode(), hashlib.sha256).hexdigest()


def constant_time_equals(a: str, b: str) -> bool:
    return hmac.compare_digest(a, b)


def hash_ip(ip: str | None) -> str | None:
    if not ip:
        return None
    return hmac.new(get_settings().jwt_secret.encode(), ip.encode(), hashlib.sha256).hexdigest()[:32]
