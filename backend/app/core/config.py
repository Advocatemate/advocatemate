"""Environment-driven configuration.

Every secret comes from the environment (or a secret manager that populates it).
Nothing in this file is a real credential; defaults are safe for local development
only and the app refuses to start in staging/production with development defaults.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_DEV_SECRET = "dev-only-change-me-0123456789abcdef0123456789abcdef"  # noqa: S105 - rejected outside dev/test


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: Literal["development", "test", "staging", "production"] = "development"
    app_name: str = "AdvocateMate API"
    api_prefix: str = "/api/v1"
    log_level: str = "INFO"

    # --- persistence -------------------------------------------------------
    database_url: str = "postgresql+psycopg://advocatemate:advocatemate@localhost:5432/advocatemate"
    redis_url: str = "redis://localhost:6379/0"
    storage_dir: str = "./var/storage"

    # --- auth ----------------------------------------------------------------
    jwt_secret: str = _DEV_SECRET
    jwt_algorithm: str = "HS256"
    jwt_issuer: str = "advocatemate"
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30
    otp_hash_secret: str = _DEV_SECRET
    otp_ttl_seconds: int = 300
    otp_length: int = 6
    otp_max_verify_attempts: int = 5
    otp_max_sends_per_hour: int = 5
    # "disabled": no OTP delivery is possible (default in staging/production until a
    #             real SMS provider is integrated and approved).
    # "dev_echo": development/test only - the OTP is returned in the API response.
    otp_provider: Literal["disabled", "dev_echo"] = "dev_echo"

    # Comma-separated list of allowed browser origins (mobile apps do not need CORS).
    cors_origins: str = ""
    rate_limit_per_minute: int = 120

    # --- upstream sources (APHC) ------------------------------------------
    upstream_enabled: bool = True
    aphc_base_url: str = "https://aphc.gov.in"
    aphc_user_agent: str = "AdvocateMate/0.1 (+server-side; contact via app support)"
    aphc_connect_timeout: float = 10.0
    aphc_read_timeout: float = 40.0
    # Minimum gap between two requests to the same upstream host from one process.
    aphc_min_interval_seconds: float = 1.5
    lexika_max_calls_per_case: int = 6

    cause_list_cache_minutes: int = 30
    advocate_lookup_cache_hours: int = 24
    live_board_poll_seconds: int = 60
    live_board_stale_seconds: int = 180
    publication_poll_minutes: int = 10

    enrichment_cache_hours: int = 12
    enrichment_max_attempts: int = 3
    enrichment_lease_seconds: int = 180
    enrichment_backoff_base_seconds: int = 60
    enrichment_dispatch_batch: int = 5

    circuit_failure_threshold: int = 5
    circuit_open_seconds: int = 300

    # --- observability / push --------------------------------------------
    sentry_dsn: str | None = None
    fcm_enabled: bool = False
    fcm_credentials_file: str | None = None

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @model_validator(mode="after")
    def _guard_production(self) -> Settings:
        if self.environment in ("staging", "production"):
            problems = []
            if self.jwt_secret == _DEV_SECRET or len(self.jwt_secret) < 32:
                problems.append("JWT_SECRET must be set to a strong unique value")
            if self.otp_hash_secret == _DEV_SECRET or len(self.otp_hash_secret) < 32:
                problems.append("OTP_HASH_SECRET must be set to a strong unique value")
            if self.otp_provider == "dev_echo":
                problems.append("OTP_PROVIDER=dev_echo is forbidden outside development/test")
            if problems:
                raise ValueError("; ".join(problems))
        return self

    @property
    def is_dev_like(self) -> bool:
        return self.environment in ("development", "test")


@lru_cache
def get_settings() -> Settings:
    return Settings()
