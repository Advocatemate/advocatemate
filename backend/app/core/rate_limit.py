"""Fixed-window rate limiting backed by Redis, with an in-process fallback.

The fallback keeps development and tests working without Redis; production runs
several API workers and must have Redis so limits are shared.
"""

from __future__ import annotations

import logging
import threading
import time

from app.core.config import get_settings
from app.core.errors import RateLimited

logger = logging.getLogger(__name__)

_local_lock = threading.Lock()
_local_counts: dict[str, tuple[int, float]] = {}
_redis = None
_redis_failed_at = 0.0


def _get_redis():
    global _redis, _redis_failed_at
    if _redis is not None:
        return _redis
    if time.monotonic() - _redis_failed_at < 30:
        return None
    try:
        import redis

        client = redis.Redis.from_url(get_settings().redis_url, socket_timeout=0.5, socket_connect_timeout=0.5)
        client.ping()
        _redis = client
        return client
    except Exception:  # noqa: BLE001
        _redis_failed_at = time.monotonic()
        if get_settings().environment in ("staging", "production"):
            logger.warning("rate limiter: redis unavailable, using per-process fallback")
        return None


def hit(key: str, limit: int, window_seconds: int) -> int:
    """Count one hit; raise RateLimited when over ``limit`` within the window."""
    bucket = int(time.time() // window_seconds)
    full_key = f"rl:{key}:{bucket}"
    r = _get_redis() if get_settings().environment != "test" else None
    if r is not None:
        try:
            pipe = r.pipeline()
            pipe.incr(full_key)
            pipe.expire(full_key, window_seconds + 1)
            count = int(pipe.execute()[0])
        except Exception:  # noqa: BLE001
            count = _local_hit(full_key, window_seconds)
    else:
        count = _local_hit(full_key, window_seconds)
    if count > limit:
        raise RateLimited("Too many requests. Please try again later.")
    return count


def _local_hit(full_key: str, window_seconds: int) -> int:
    now = time.time()
    with _local_lock:
        count, expires = _local_counts.get(full_key, (0, now + window_seconds))
        if now > expires:
            count, expires = 0, now + window_seconds
        count += 1
        _local_counts[full_key] = (count, expires)
        if len(_local_counts) > 50_000:
            for k in [k for k, (_, e) in _local_counts.items() if e < now]:
                _local_counts.pop(k, None)
        return count


def reset_local() -> None:
    with _local_lock:
        _local_counts.clear()
