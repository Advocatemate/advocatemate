import logging

from app.core.logging import JsonFormatter, redact_mapping, redact_text
from app.core.security import create_access_token, decode_access_token, hash_otp, hash_token
from app.services.auth import mask_phone


def test_redaction_of_secrets_in_text_and_mappings():
    assert "123456" not in redact_text("otp=123456 sent")
    assert "abc.def" not in redact_text("Authorization: Bearer abc.def")
    assert redact_mapping({"refresh_token": "x", "nested": {"cookie": "PHPSESSID=1"}, "ok": 1}) == {
        "refresh_token": "<redacted>", "nested": {"cookie": "<redacted>"}, "ok": 1}


def test_json_formatter_redacts_extra_fields():
    rec = logging.LogRecord("t", logging.INFO, __file__, 1, "token=supersecret", None, None)
    rec.extra_fields = {"otp": "999999", "case": "WP/1/2026"}
    out = JsonFormatter().format(rec)
    assert "supersecret" not in out and "999999" not in out and "WP/1/2026" in out


def test_tokens_and_hashes():
    import uuid

    token, ttl = create_access_token(user_id=uuid.uuid4(), session_id=uuid.uuid4(), role="advocate")
    assert decode_access_token(token)["role"] == "advocate" and ttl > 0
    assert hash_token("a") != "a" and hash_token("a") == hash_token("a")
    assert hash_otp("+919876543210", "123456", "s1") != hash_otp("+919876543210", "123456", "s2")


def test_phone_masking():
    assert mask_phone("+919876543210") == "+91******3210"


def test_production_refuses_dev_defaults(monkeypatch):
    import pytest
    from pydantic import ValidationError

    from app.core.config import Settings

    with pytest.raises(ValidationError):
        Settings(environment="production", jwt_secret="x" * 40, otp_hash_secret="y" * 40, otp_provider="dev_echo")
    with pytest.raises(ValidationError):
        Settings(environment="production", jwt_secret="too-short", otp_hash_secret="y" * 40, otp_provider="disabled")
    with pytest.raises(ValidationError):  # Google sign-in client IDs are mandatory outside dev/test
        Settings(environment="production", jwt_secret="x" * 40, otp_hash_secret="y" * 40, otp_provider="disabled",
                 google_client_ids="")
    ok = Settings(environment="production", jwt_secret="x" * 40, otp_hash_secret="y" * 40, otp_provider="disabled",
                  google_client_ids="web-client.apps.googleusercontent.com")
    assert ok.environment == "production"
