"""Structured JSON logging with secret redaction."""

from __future__ import annotations

import contextvars
import json
import logging
import re
import sys
from datetime import UTC, datetime

request_id_var: contextvars.ContextVar[str | None] = contextvars.ContextVar("request_id", default=None)

_SENSITIVE_KEYS = re.compile(
    r"(otp|password|passwd|secret|token|authorization|cookie|session|phpsessid|hcdbs_id|api[_-]?key)",
    re.IGNORECASE,
)
# key=value / key: value / "key": "value" patterns for free-text messages
_KV_PATTERN = re.compile(
    r"(?i)(\"?(?:otp|password|secret|token|access_token|refresh_token|authorization|cookie|phpsessid|hcdbs_id)\"?\s*[:=]\s*)(\"[^\"]*\"|[^\s,;]+)"
)
_BEARER = re.compile(r"(?i)bearer\s+[A-Za-z0-9._\-]+")


def redact_text(text: str) -> str:
    text = _BEARER.sub("Bearer <redacted>", text)
    return _KV_PATTERN.sub(lambda m: m.group(1) + "<redacted>", text)


def redact_mapping(data):
    if isinstance(data, dict):
        return {
            k: ("<redacted>" if _SENSITIVE_KEYS.search(str(k)) else redact_mapping(v)) for k, v in data.items()
        }
    if isinstance(data, list | tuple):
        return [redact_mapping(v) for v in data]
    if isinstance(data, str):
        return redact_text(data)
    return data


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "ts": datetime.now(UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "msg": redact_text(record.getMessage()),
        }
        rid = request_id_var.get()
        if rid:
            payload["request_id"] = rid
        extra = getattr(record, "extra_fields", None)
        if extra:
            payload.update(redact_mapping(extra))
        if record.exc_info:
            payload["exc"] = redact_text(self.formatException(record.exc_info))
        return json.dumps(payload, default=str)


def configure_logging(level: str = "INFO") -> None:
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    root = logging.getLogger()
    root.handlers[:] = [handler]
    root.setLevel(level)
    # httpx logs full URLs at INFO; keep it quiet.
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)


def log_event(logger: logging.Logger, level: int, msg: str, **fields) -> None:
    logger.log(level, msg, extra={"extra_fields": fields})
