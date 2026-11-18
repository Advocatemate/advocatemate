from __future__ import annotations

import secrets

from fastapi import APIRouter, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.api.v1 import admin, auth, court_data, personal
from app.core.config import get_settings
from app.core.errors import install_error_handlers
from app.core.logging import configure_logging, request_id_var
from app.db.session import get_engine


def create_app() -> FastAPI:
    s = get_settings()
    configure_logging(s.log_level)
    if s.sentry_dsn:
        import sentry_sdk

        sentry_sdk.init(dsn=s.sentry_dsn, environment=s.environment, send_default_pii=False, traces_sample_rate=0.05)

    app = FastAPI(
        title=s.app_name,
        version="0.1.0",
        description=(
            "Backend for the AdvocateMate Andhra Pradesh High Court advocate app. Court data is retrieved "
            "server-side from public APHC sources (aphc.gov.in Hcdbs pages and the Lexika chatbot). "
            "These /api/v1 routes are AdvocateMate's own API, not APHC endpoints."
        ),
        docs_url="/docs" if s.environment != "production" else None,
        redoc_url="/redoc" if s.environment != "production" else None,
        openapi_url="/openapi.json" if s.environment != "production" else None,
    )
    install_error_handlers(app)
    if s.cors_origin_list:
        app.add_middleware(CORSMiddleware, allow_origins=s.cors_origin_list, allow_methods=["GET", "POST", "PUT",
                           "PATCH", "DELETE"], allow_headers=["Authorization", "Content-Type"], allow_credentials=False)

    @app.middleware("http")
    async def request_context(request: Request, call_next):
        rid = request.headers.get("x-request-id")
        if not rid or len(rid) > 64 or not rid.replace("-", "").isalnum():
            rid = secrets.token_hex(8)
        token = request_id_var.set(rid)
        try:
            response = await call_next(request)
        finally:
            request_id_var.reset(token)
        response.headers["X-Request-ID"] = rid
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Referrer-Policy"] = "no-referrer"
        if s.environment in ("staging", "production"):
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        return response

    api = APIRouter(prefix=s.api_prefix)
    api.include_router(auth.router)
    api.include_router(court_data.router)
    api.include_router(personal.router)
    api.include_router(admin.router)
    app.include_router(api)

    @app.get("/health/live", tags=["health"])
    def live():
        return {"status": "ok"}

    @app.get("/health/ready", tags=["health"])
    def ready():
        with get_engine().connect() as conn:
            conn.execute(text("SELECT 1"))
        return {"status": "ready", "environment": s.environment}

    return app


app = create_app()
