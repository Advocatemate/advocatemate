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
    # --- Google sign-in -------------------------------------------------------
    # Comma-separated OAuth client IDs an ID token may be issued for (its "aud" claim). Use the
    # Web client ID that the mobile apps pass as serverClientId. Not secrets, but must be correct.
    google_client_ids: str = ""
    google_link_token_minutes: int = 10

    # Admin portal (/admin): Google Web client used by the sign-in button (defaults to the first
    # GOOGLE_CLIENT_IDS entry), session limits, re-authentication window, optional IP allow-list.
    admin_google_client_id: str = ""
    admin_session_idle_minutes: int = 30
    admin_session_max_hours: int = 8
    admin_reauth_minutes: int = 10
    admin_allowed_ips: str = ""  # comma-separated IPs/CIDRs; empty = rely on the reverse proxy

    # Admin App JSON API (/admin-api/v1) for the separate AdvocateMate Admin web app, reached only through that
    # app's reverse proxy. None = on in development/test, off in staging/production unless set to true.
    admin_api_enabled: bool | None = None
    # Browser origins of the Admin App (e.g. https://admin.advocatemate.com); state-changing requests from any
    # other Origin are refused. Development/test default: the Vite dev server.
    admin_app_origins: str = ""
    # Shared secret the Admin App's reverse proxy sends as X-Admin-Proxy-Key; required in staging/production.
    admin_proxy_secret: str = ""

    # Retired mobile-OTP login (kept only so existing configuration still loads).
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
    def google_client_id_list(self) -> list[str]:
        return [c.strip() for c in self.google_client_ids.split(",") if c.strip()]

    @property
    def admin_client_id(self) -> str:
        return self.admin_google_client_id or (self.google_client_id_list[0] if self.google_client_id_list else "")

    @property
    def admin_allowed_networks(self) -> list[str]:
        return [c.strip() for c in self.admin_allowed_ips.split(",") if c.strip()]

    @property
    def admin_api_on(self) -> bool:
        return self.is_dev_like if self.admin_api_enabled is None else self.admin_api_enabled

    @property
    def admin_app_origin_list(self) -> list[str]:
        origins = [o.strip().rstrip("/") for o in self.admin_app_origins.split(",") if o.strip()]
        if not origins and self.is_dev_like:
            return ["http://localhost:5173", "http://127.0.0.1:5173"]
        return origins

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
            if not self.google_client_id_list:
                problems.append("GOOGLE_CLIENT_IDS must list the OAuth client ID(s) used for Google sign-in")
            if self.admin_api_enabled:
                if len(self.admin_proxy_secret) < 32:
                    problems.append("ADMIN_PROXY_SECRET (32+ characters) is required when ADMIN_API_ENABLED=true")
                if not self.admin_app_origin_list or any(not o.startswith("https://")
                                                         for o in self.admin_app_origin_list):
                    problems.append("ADMIN_APP_ORIGINS must list the Admin App's https:// origin(s)")
            if problems:
                raise ValueError("; ".join(problems))
        return self

    @property
    def is_dev_like(self) -> bool:
        return self.environment in ("development", "test")


@lru_cache
def get_settings() -> Settings:
    return Settings()
