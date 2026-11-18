from __future__ import annotations

from contextlib import contextmanager

from app.core.errors import AppError, NotFound, ServiceUnavailable, UpstreamFailure
from app.integrations.http import UpstreamDisabled, UpstreamError, UpstreamNotFound
from app.services.circuit import CircuitOpen

_MESSAGES = {
    "upstream_timeout": "The court website did not respond in time. Please try again shortly.",
    "upstream_unavailable": "The court website is currently unavailable.",
    "upstream_blocked": "The court website refused this request.",
    "upstream_protocol_error": "The court website responded in an unexpected way.",
    "parser_failure": "The court website's page format has changed; this data is temporarily unavailable.",
    "upstream_session_expired": "The court website session expired. Please retry.",
    "identity_mismatch": "The court website returned a different case than requested.",
}


def to_app_error(e: UpstreamError) -> AppError:
    if isinstance(e, UpstreamNotFound):
        return NotFound("No matching record was found on the court website", code="not_found")
    if isinstance(e, CircuitOpen):
        return ServiceUnavailable(
            "This court data source is temporarily paused after repeated failures.", code="source_paused"
        )
    if isinstance(e, UpstreamDisabled):
        return ServiceUnavailable("Live court sources are disabled in this environment.", code="upstream_disabled")
    return UpstreamFailure(_MESSAGES.get(e.code, "The court website request failed."), code=e.code)


@contextmanager
def translate_upstream():
    try:
        yield
    except UpstreamError as e:
        raise to_app_error(e) from e
