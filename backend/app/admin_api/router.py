"""Mounts /admin-api/v1 when enabled (ADMIN_API_ENABLED; on by default only in development/test)."""

from __future__ import annotations

from fastapi import APIRouter, FastAPI, Request
from fastapi.responses import JSONResponse

from app.admin_api import auth, deps
from app.core.config import get_settings

# Responses are JSON only: nothing may be framed, cached or indexed.
API_HEADERS = {
    "Cache-Control": "no-store",
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
    "X-Frame-Options": "DENY",
    "X-Robots-Tag": "noindex, nofollow",
}


def _is_admin_api(path: str) -> bool:
    return path == "/admin-api" or path.startswith("/admin-api/")


def install(app: FastAPI) -> None:
    s = get_settings()
    if not s.admin_api_on:
        return
    # Like the portal, never listed in the API documentation.
    api = APIRouter(prefix=deps.PREFIX, include_in_schema=False)
    api.include_router(auth.router)
    app.include_router(api)

    @app.middleware("http")
    async def admin_api_gate(request: Request, call_next):
        if not _is_admin_api(request.url.path):
            return await call_next(request)
        if not deps.gate_allows(request):
            # Same answer as a route that does not exist: the API is not discoverable without the proxy.
            response = JSONResponse(status_code=404, content={"error": {"code": "not_found", "message": "Not found"}})
        else:
            response = await call_next(request)
        for name, value in API_HEADERS.items():
            response.headers[name] = value
        return response
