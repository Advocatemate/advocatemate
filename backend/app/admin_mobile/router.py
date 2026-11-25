"""Mounts /admin-mobile/v1 when enabled (ADMIN_MOBILE_API_ENABLED; on by default only in development/test)."""

from __future__ import annotations

from fastapi import APIRouter, FastAPI, Request

from app.admin_mobile import auth, deps
from app.core.config import get_settings

API_HEADERS = {
    "Cache-Control": "no-store",
    "X-Robots-Tag": "noindex, nofollow",
}


def _is_mobile_api(path: str) -> bool:
    return path == "/admin-mobile" or path.startswith("/admin-mobile/")


def install(app: FastAPI) -> None:
    if not get_settings().admin_mobile_api_on:
        return
    # Like the other admin surfaces, never listed in the API documentation.
    api = APIRouter(prefix=deps.PREFIX, include_in_schema=False)
    api.include_router(auth.router)
    app.include_router(api)

    @app.middleware("http")
    async def admin_mobile_headers(request: Request, call_next):
        response = await call_next(request)
        if _is_mobile_api(request.url.path):
            for name, value in API_HEADERS.items():
                response.headers[name] = value
        return response
