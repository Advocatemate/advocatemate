# AdvocateMate

Android & iOS app and backend for advocates of the **High Court of Andhra Pradesh**: personal cause lists,
daily / weekly / supplementary lists, court-wise listings, case details, official PDFs, live court display,
favourites, notifications, offline mode, English & Telugu.

> Court data comes from public APHC sources and is fetched only by the backend. AdvocateMate is not an official
> court service. Always verify against the official cause list.

```
advocatemate/
├── mobile/            Flutter app (Android + iOS)
├── backend/           FastAPI + SQLAlchemy + Alembic + Celery
├── infrastructure/    deployment notes / future IaC
├── docs/              architecture, API, integrations, security, releases, progress
├── .github/workflows/ CI (backend tests on PostgreSQL, Flutter analyze/test, Android/iOS build checks)
├── docker-compose.yml local stack (PostgreSQL, Redis, API, workers, beat)
└── .env.example
```

## Quick start
```
cp .env.example .env            # set JWT_SECRET and OTP_HASH_SECRET
docker compose up --build       # API on http://localhost:8000/docs
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
```
In development, `OTP_PROVIDER=dev_echo` shows the OTP in the app (never allowed in staging/production).

## Tests
```
cd backend && pytest            # needs TEST_DATABASE_URL (PostgreSQL)
cd mobile && flutter analyze && flutter test
```
Current results and what has *not* been run (device integration tests, Android/iOS builds) are in
[docs/TESTING.md](docs/TESTING.md).

## Key documents
* [Development progress & outstanding dependencies](docs/DEVELOPMENT_PROGRESS.md)
* [APHC integration (verified contracts)](docs/APHC_INTEGRATION.md) · [Lexika integration](docs/LEXIKA_INTEGRATION.md)
* [Architecture](docs/ARCHITECTURE.md) · [Database](docs/DATABASE_SCHEMA.md) · [API](docs/API_DOCUMENTATION.md)
* [Authentication](docs/AUTHENTICATION.md) · [Security](docs/SECURITY.md)
* [Android release](docs/ANDROID_RELEASE.md) · [iOS release](docs/IOS_RELEASE.md) · [Deployment](docs/DEPLOYMENT.md)
