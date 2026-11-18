# syntax=docker/dockerfile:1
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt requirements-push.txt ./
ARG WITH_PUSH=false
RUN pip install -r requirements.txt && if [ "$WITH_PUSH" = "true" ]; then pip install -r requirements-push.txt; fi

COPY app ./app
COPY migrations ./migrations
COPY alembic.ini ./
COPY docker/entrypoint.sh /entrypoint.sh

RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /var/lib/advocatemate && chown appuser /var/lib/advocatemate \
    && chmod +x /entrypoint.sh
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -fsS http://localhost:8000/health/live || exit 1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["api"]
