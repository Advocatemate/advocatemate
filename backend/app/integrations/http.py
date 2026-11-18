"""Shared, polite HTTP plumbing for APHC sources.

* HTTPS with certificate verification (httpx default; never disabled).
* One cookie jar per logical upstream session (``new_client``) - cookies never
  leave the backend and are never logged.
* Per-host minimum interval between requests (process-wide).
* Redirects are NOT followed: none of the verified flows redirect, so a redirect
  is treated as a protocol change / expired session rather than silently followed.
* Errors are classified so callers can distinguish not-found, blocked, timeout,
  unavailable and parser failures (handover section 9).
"""

from __future__ import annotations

import threading
import time
from urllib.parse import urlparse

import httpx

from app.core.config import get_settings


class UpstreamError(Exception):
    code = "upstream_error"
    retryable = True

    def __init__(self, message: str, *, status: int | None = None):
        super().__init__(message)
        self.status = status


class UpstreamTimeout(UpstreamError):
    code = "upstream_timeout"


class UpstreamUnavailable(UpstreamError):
    code = "upstream_unavailable"


class UpstreamBlocked(UpstreamError):
    """The source served its 'URL cannot be found' block page or a 403/404."""

    code = "upstream_blocked"
    retryable = False


class UpstreamSessionExpired(UpstreamError):
    code = "upstream_session_expired"


class UpstreamProtocolError(UpstreamError):
    """Unexpected redirect/response shape - the contract may have changed."""

    code = "upstream_protocol_error"
    retryable = False


class UpstreamParseError(UpstreamError):
    code = "parser_failure"
    retryable = False


class UpstreamNotFound(UpstreamError):
    """The source answered normally but has no such record."""

    code = "not_found"
    retryable = False


class UpstreamIdentityMismatch(UpstreamError):
    code = "identity_mismatch"
    retryable = False


class UpstreamDisabled(UpstreamError):
    code = "upstream_disabled"
    retryable = False


_BLOCK_PAGE_MARKER = "The specified URL cannot be found"

_throttle_lock = threading.Lock()
_last_request_at: dict[str, float] = {}


def _throttle(host: str) -> None:
    gap = get_settings().aphc_min_interval_seconds
    if gap <= 0:
        return
    with _throttle_lock:
        now = time.monotonic()
        wait = _last_request_at.get(host, 0.0) + gap - now
        if wait > 0:
            time.sleep(wait)
        _last_request_at[host] = time.monotonic()


def new_client() -> httpx.Client:
    s = get_settings()
    if not s.upstream_enabled:
        raise UpstreamDisabled("upstream access is disabled in this environment")
    return httpx.Client(
        base_url=s.aphc_base_url,
        headers={"User-Agent": s.aphc_user_agent, "Accept-Language": "en-IN,en;q=0.8"},
        timeout=httpx.Timeout(s.aphc_read_timeout, connect=s.aphc_connect_timeout),
        follow_redirects=False,
        verify=True,
    )


def request(client: httpx.Client, method: str, url: str, **kwargs) -> httpx.Response:
    host = urlparse(str(client.base_url.join(url))).netloc
    _throttle(host)
    try:
        resp = client.request(method, url, **kwargs)
    except httpx.TimeoutException as e:
        raise UpstreamTimeout(f"timeout calling {urlparse(url).path}") from e
    except httpx.TransportError as e:
        raise UpstreamUnavailable(f"transport error calling {urlparse(url).path}") from e

    if resp.is_redirect:
        raise UpstreamProtocolError(f"unexpected redirect ({resp.status_code})", status=resp.status_code)
    if resp.status_code in (403, 404) or (
        resp.status_code >= 400 and _BLOCK_PAGE_MARKER in resp.text[:2000]
    ):
        raise UpstreamBlocked(f"source refused request ({resp.status_code})", status=resp.status_code)
    if resp.status_code >= 500:
        raise UpstreamUnavailable(f"source error ({resp.status_code})", status=resp.status_code)
    if resp.status_code >= 400:
        raise UpstreamProtocolError(f"unexpected status ({resp.status_code})", status=resp.status_code)
    return resp
