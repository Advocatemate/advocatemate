from __future__ import annotations

from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, client_ip, get_current_user
from app.core import rate_limit
from app.core.errors import AppError
from app.db.session import get_db
from app.models import VerifiedMobile
from app.schemas import GoogleLinkIn, GoogleSignInIn, GoogleSignInOut, MeOut, ProfileUpdateIn, RefreshIn, TokenOut
from app.services import audit, google_auth
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/google", response_model=GoogleSignInOut, response_model_exclude_none=True,
             summary="Step 1: verify a Google ID token on the server")
def google_sign_in(body: GoogleSignInIn, request: Request, db: Session = Depends(get_db)):
    """Returns a session straight away when this Google account is already linked to an eligible
    advocate (Scenario B); otherwise `advocate_code_required` with a short-lived link token."""
    return google_auth.sign_in_with_google(db, body.id_token, device_label=body.device_label,
                                           user_agent=request.headers.get("user-agent"), ip=client_ip(request))


@router.post("/google/link", response_model=GoogleSignInOut, response_model_exclude_none=True,
             summary="Step 2: link the verified Google account to an advocate code (automatic registry check)")
def google_link(body: GoogleLinkIn, request: Request, db: Session = Depends(get_db)):
    return google_auth.link_advocate(db, body.link_token, body.advocate_code, device_label=body.device_label,
                                     user_agent=request.headers.get("user-agent"), ip=client_ip(request))


def _retired():
    raise AppError("This sign-in method has been replaced by Google sign-in. Please update the app.",
                   code="login_method_retired", status_code=410)


@router.post("/register", include_in_schema=False)
def register_retired():
    _retired()


@router.post("/send-otp", include_in_schema=False)
def send_otp_retired():
    _retired()


@router.post("/verify-otp", include_in_schema=False)
def verify_otp_retired():
    _retired()


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
        "google_email": p.google_email if p else None,
        "identity_verification": p.identity_verification if p else None,
        "verification_method": p.verification_method if p else None,
        "linked_at": p.linked_at if p else None,
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
