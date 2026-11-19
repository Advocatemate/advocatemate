"""Server-side verification of Google ID tokens.

Uses Google's official ``google-auth`` library: the token's signature is checked against
Google's published certificates, and the issuer, expiry and audience (our OAuth client IDs)
are validated. Only the verified token contents are trusted - never an email or account ID
sent separately by the app.
"""

from __future__ import annotations

from dataclasses import dataclass

import requests
from google.auth import exceptions as google_exceptions
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

from app.core.config import get_settings
from app.core.errors import ServiceUnavailable, Unauthorized


@dataclass(frozen=True)
class GoogleIdentity:
    sub: str  # Google's stable account identifier
    email: str  # lower-cased
    email_verified: bool
    name: str | None = None


_session = requests.Session()


def _transport() -> google_requests.Request:
    # A shared session lets google-auth reuse its HTTP connection; certificates are cached by Google's
    # Cache-Control headers inside the library.
    return google_requests.Request(session=_session)


def verify_id_token(token: str, *, transport=None) -> GoogleIdentity:
    audiences = get_settings().google_client_id_list
    if not audiences:
        raise ServiceUnavailable("Google sign-in is not configured on this server.", code="google_signin_not_configured")
    if not token or len(token) > 8192:
        raise Unauthorized("Google sign-in failed. Please try again.", code="google_token_invalid")
    try:
        info = google_id_token.verify_oauth2_token(token, transport or _transport(), audience=audiences)
    except google_exceptions.TransportError as e:
        raise ServiceUnavailable("Could not reach Google to verify sign-in. Please try again.",
                                 code="google_unreachable") from e
    except (ValueError, google_exceptions.GoogleAuthError) as e:
        # Bad signature, wrong audience/issuer, expired, malformed.
        raise Unauthorized("Google sign-in failed. Please try again.", code="google_token_invalid") from e

    sub = str(info.get("sub") or "").strip()
    email = str(info.get("email") or "").strip().lower()
    verified = info.get("email_verified") in (True, "true")
    if not sub or not email:
        raise Unauthorized("Google sign-in did not provide an account email.", code="google_token_invalid")
    if not verified:
        raise Unauthorized("Your Google account email is not verified.", code="google_email_unverified")
    return GoogleIdentity(sub=sub, email=email, email_verified=verified, name=info.get("name"))
