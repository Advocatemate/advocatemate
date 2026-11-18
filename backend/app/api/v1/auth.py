from __future__ import annotations

from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, client_ip, get_current_user
from app.core import rate_limit
from app.core.errors import AppError
from app.db.session import get_db
from app.models import VerifiedMobile
from app.schemas import (
    MeOut,
    ProfileUpdateIn,
    RefreshIn,
    RegisterIn,
    RegisterOut,
    SendOtpIn,
    SendOtpOut,
    TokenOut,
    VerifyOtpIn,
)
from app.services import audit
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/register", response_model=RegisterOut, summary="Validate an advocate code against APHC")
def register(body: RegisterIn, request: Request, db: Session = Depends(get_db)):
    rate_limit.hit(f"register:{client_ip(request)}", 20, 3600)
    return auth_service.register(db, body.advocate_code)


@router.post("/send-otp", response_model=SendOtpOut)
def send_otp(body: SendOtpIn, request: Request, db: Session = Depends(get_db)):
    if not body.identity_confirmed:
        raise AppError("Please confirm the advocate details are yours", code="identity_not_confirmed",
                       status_code=422)
    return auth_service.send_otp(db, body.advocate_code, body.mobile, client_ip(request))


@router.post("/verify-otp", response_model=TokenOut)
def verify_otp(body: VerifyOtpIn, request: Request, db: Session = Depends(get_db)):
    return auth_service.verify_otp(db, body.advocate_code, body.mobile, body.otp, device_label=body.device_label,
                                   user_agent=request.headers.get("user-agent"), ip=client_ip(request))


@router.post("/refresh", response_model=TokenOut)
def refresh(body: RefreshIn, request: Request, db: Session = Depends(get_db)):
    rate_limit.hit(f"refresh:{client_ip(request)}", 60, 60)
    return auth_service.refresh(db, body.refresh_token)


@router.post("/logout", status_code=204)
def logout(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    auth_service.logout(db, current.session_id, current.id)


def me_payload(db: Session, current: CurrentUser) -> dict:
    mobile = db.scalar(select(VerifiedMobile).where(VerifiedMobile.user_id == current.id,
                                                   VerifiedMobile.is_primary.is_(True)))
    p = current.profile
    return {
        "user_id": str(current.id),
        "role": current.user.role,
        "preferred_language": current.user.preferred_language,
        "advocate_code": p.advocate_code if p else None,
        "advocate_name": p.source_name if p else None,
        "display_name": p.display_name if p else None,
        "email": p.email if p else None,
        "identity_verification": p.identity_verification if p else None,
        "mobile": auth_service.mask_phone(mobile.phone_e164) if mobile else None,
        "created_at": current.user.created_at,
    }


@router.get("/me", response_model=MeOut)
def me(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    return me_payload(db, current)


@router.patch("/me", response_model=MeOut, summary="Update user-editable profile fields")
def update_me(body: ProfileUpdateIn, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    changed = body.model_dump(exclude_unset=True)
    if "preferred_language" in changed and changed["preferred_language"]:
        current.user.preferred_language = changed["preferred_language"]
    if current.profile:
        if "display_name" in changed:
            current.profile.display_name = changed["display_name"] or None
        if "email" in changed:
            current.profile.email = str(changed["email"]) if changed["email"] else None
    audit.record(db, "profile_updated", actor=current.id, fields=sorted(changed))
    db.flush()
    return me_payload(db, current)
