from __future__ import annotations

import uuid
from dataclasses import dataclass

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import Forbidden, Unauthorized
from app.core.security import decode_access_token
from app.db.base import utcnow
from app.db.session import get_db
from app.models import AdvocateProfile, AuthSession, User

bearer = HTTPBearer(auto_error=False)


@dataclass
class CurrentUser:
    user: User
    session_id: uuid.UUID
    profile: AdvocateProfile | None

    @property
    def id(self) -> uuid.UUID:
        return self.user.id

    @property
    def is_admin(self) -> bool:
        return self.user.role == "admin"


def client_ip(request: Request) -> str | None:
    return request.client.host if request.client else None


def rate_limited(request: Request) -> None:
    ip = client_ip(request) or "unknown"
    rate_limit.hit(f"ip:{ip}", get_settings().rate_limit_per_minute, 60)


def get_current_user(
    creds: HTTPAuthorizationCredentials | None = Depends(bearer),
    db: Session = Depends(get_db),
) -> CurrentUser:
    if creds is None or creds.scheme.lower() != "bearer":
        raise Unauthorized("Authentication required")
    claims = decode_access_token(creds.credentials)
    try:
        user_id = uuid.UUID(claims["sub"])
        session_id = uuid.UUID(claims["sid"])
    except (KeyError, ValueError) as e:
        raise Unauthorized("Invalid access token", code="invalid_token") from e
    session = db.get(AuthSession, session_id)
    if session is None or session.revoked_at is not None or session.user_id != user_id:
        raise Unauthorized("Session is no longer valid", code="session_revoked")
    user = db.get(User, user_id)
    if user is None or user.status != "active" or user.deleted_at is not None:
        raise Unauthorized("Account is not active", code="account_inactive")
    session.last_seen_at = utcnow()
    profile = db.query(AdvocateProfile).filter(AdvocateProfile.user_id == user.id).one_or_none()
    rate_limit.hit(f"user:{user.id}", get_settings().rate_limit_per_minute, 60)
    return CurrentUser(user=user, session_id=session_id, profile=profile)


def require_admin(current: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    if not current.is_admin:
        raise Forbidden("Administrator access required")
    return current
