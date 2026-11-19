"""The REAL Google ID-token verifier (google-auth), against tokens signed with a local test key.

Google's certificate endpoint is replaced by a fake transport serving our test certificate, so the
full signature / audience / issuer / expiry checks run exactly as in production.
"""

import json
import time
from datetime import UTC, datetime, timedelta

import pytest
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID
from google.auth import crypt
from google.auth import jwt as google_jwt

from app.core.errors import ServiceUnavailable, Unauthorized
from app.integrations.google_identity import verify_id_token  # real function, captured before patching

AUDIENCE = "test-web-client.apps.googleusercontent.com"


def _key_and_cert():
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "test-google-signer")])
    now = datetime.now(UTC)
    cert = (x509.CertificateBuilder().subject_name(name).issuer_name(name).public_key(key.public_key())
            .serial_number(x509.random_serial_number()).not_valid_before(now - timedelta(days=1))
            .not_valid_after(now + timedelta(days=1)).sign(key, hashes.SHA256()))
    pem_key = key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
                                serialization.NoEncryption()).decode()
    return pem_key, cert.public_bytes(serialization.Encoding.PEM).decode()


KEY_PEM, CERT_PEM = _key_and_cert()
OTHER_KEY_PEM, _ = _key_and_cert()
KID = "test-kid"


class FakeResponse:
    status = 200
    headers: dict = {}

    def __init__(self, data: bytes):
        self.data = data


class FakeTransport:
    """google.auth.transport.Request stand-in: serves our certificate as Google's cert set."""

    def __call__(self, url, method="GET", **kwargs):
        assert "googleapis.com" in url
        return FakeResponse(json.dumps({KID: CERT_PEM}).encode())


def make_token(*, key_pem=KEY_PEM, **overrides) -> str:
    now = int(time.time())
    claims = {"iss": "https://accounts.google.com", "aud": AUDIENCE, "sub": "1234567890",
              "email": "Adv.One@Example.com", "email_verified": True, "iat": now, "exp": now + 600,
              "name": "Advocate One"}
    claims.update(overrides)
    signer = crypt.RSASigner.from_string(key_pem, key_id=KID)
    return google_jwt.encode(signer, claims).decode()


def verify(token):
    return verify_id_token(token, transport=FakeTransport())


def test_valid_token_returns_verified_identity():
    ident = verify(make_token())
    assert (ident.sub, ident.email, ident.email_verified) == ("1234567890", "adv.one@example.com", True)


@pytest.mark.parametrize("overrides", [
    {"aud": "someone-elses-client.apps.googleusercontent.com"},  # token minted for another app
    {"iss": "https://evil.example.com"},
    {"exp": int(time.time()) - 3600, "iat": int(time.time()) - 7200},  # expired
])
def test_wrong_audience_issuer_or_expired_rejected(overrides):
    with pytest.raises(Unauthorized) as e:
        verify(make_token(**overrides))
    assert e.value.code == "google_token_invalid"


def test_signature_from_another_key_rejected():
    with pytest.raises(Unauthorized) as e:
        verify(make_token(key_pem=OTHER_KEY_PEM))
    assert e.value.code == "google_token_invalid"


def test_unverified_email_rejected():
    with pytest.raises(Unauthorized) as e:
        verify(make_token(email_verified=False))
    assert e.value.code == "google_email_unverified"


def test_missing_email_rejected():
    with pytest.raises(Unauthorized):
        verify(make_token(email=""))


def test_garbage_rejected():
    with pytest.raises(Unauthorized):
        verify("definitely.not.a-jwt-token")


def test_not_configured(monkeypatch):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "google_client_ids", "")
    with pytest.raises(ServiceUnavailable) as e:
        verify(make_token())
    assert e.value.code == "google_signin_not_configured"


def test_multiple_allowed_client_ids(monkeypatch):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "google_client_ids", f"other-client, {AUDIENCE}")
    assert verify(make_token()).sub == "1234567890"
