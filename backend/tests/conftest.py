"""Test configuration.

Uses PostgreSQL when TEST_DATABASE_URL is set (CI / docker compose), otherwise a
temporary SQLite file. Upstream access is disabled: APHC/Lexika are replaced by
fakes that run the REAL parsers over synthetic fixtures mirroring captured pages.
"""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

_TMP = tempfile.mkdtemp(prefix="advocatemate-tests-")
os.environ.update(
    ENVIRONMENT="test",
    DATABASE_URL=os.environ.get("TEST_DATABASE_URL") or f"sqlite:///{_TMP}/test.db",
    UPSTREAM_ENABLED="false",
    APHC_MIN_INTERVAL_SECONDS="0",
    STORAGE_DIR=_TMP,
    OTP_PROVIDER="dev_echo",
    JWT_SECRET="test-secret-test-secret-test-secret-1234",
    OTP_HASH_SECRET="test-otp-secret-test-otp-secret-123456",
    FCM_ENABLED="false",
    GOOGLE_CLIENT_IDS="test-web-client.apps.googleusercontent.com",
)

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import create_engine  # noqa: E402

import app.models  # noqa: E402,F401
from app.core import rate_limit  # noqa: E402
from app.core.errors import Unauthorized  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.session import set_engine  # noqa: E402
from app.integrations import google_identity  # noqa: E402
from app.integrations.aphc import parsers as aphc_parsers  # noqa: E402
from app.integrations.google_identity import GoogleIdentity  # noqa: E402
from app.integrations.lexika import parsers as lx  # noqa: E402
from app.integrations.lexika.client import CaseStatusResult  # noqa: E402
from app.services import sources  # noqa: E402
from app.utils.case_identity import CaseIdentity  # noqa: E402

FIXTURES = Path(__file__).parent / "fixtures"


def fixture_text(rel: str) -> str:
    return (FIXTURES / rel).read_text(encoding="utf-8")


@pytest.fixture(scope="session")
def engine():
    url = os.environ["DATABASE_URL"]
    eng = create_engine(url, future=True, **({"connect_args": {"check_same_thread": False}}
                                              if url.startswith("sqlite") else {}))
    Base.metadata.drop_all(eng)
    Base.metadata.create_all(eng)
    set_engine(eng)
    yield eng
    eng.dispose()


@pytest.fixture(autouse=True)
def clean_db(engine):
    rate_limit.reset_local()
    with engine.begin() as conn:
        for table in reversed(Base.metadata.sorted_tables):
            conn.execute(table.delete())
    yield


def load_sample_registry() -> None:
    """Fictional registry (tests/fixtures/registry/sample_registry.csv), loaded via the real importer."""
    import csv

    from app.db.session import db_session
    from app.services.registry import import_rows

    with open(FIXTURES / "registry" / "sample_registry.csv", newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    with db_session() as db:
        import_rows(db, rows, source="sample-test-registry")


@pytest.fixture(autouse=True)
def sample_registry(clean_db):
    load_sample_registry()


def fake_google_token(sub: str, email: str, *, verified: bool = True, nonce: str | None = None) -> str:
    """Stands in for a Google ID token in API tests (the real verifier has its own tests)."""
    token = f"fake-google-id-token:{sub}:{email}:{'1' if verified else '0'}"
    return f"{token}:{nonce}" if nonce else token


fake_google_audiences: list = []  # audiences each fake verification was asked for (None = default)


@pytest.fixture(autouse=True)
def fake_google(monkeypatch):
    fake_google_audiences.clear()
    def verify(token: str, *, transport=None, audiences=None) -> GoogleIdentity:
        fake_google_audiences.append(audiences)
        parts = (token or "").split(":")
        if len(parts) not in (4, 5) or parts[0] != "fake-google-id-token":
            raise Unauthorized("Google sign-in failed. Please try again.", code="google_token_invalid")
        if parts[3] != "1":
            raise Unauthorized("Your Google account email is not verified.", code="google_email_unverified")
        return GoogleIdentity(sub=parts[1], email=parts[2].lower(), email_verified=True,
                              nonce=parts[4] if len(parts) == 5 else None)

    monkeypatch.setattr(google_identity, "verify_id_token", verify)


# ---------------------------------------------------------------- fakes
class FakeSession:
    def __init__(self, owner, list_type, list_date):
        self.owner, self.list_type, self.list_date = owner, list_type, list_date

    def __enter__(self):
        return self

    def __exit__(self, *a):
        pass

    def courts(self):
        self.owner.calls.append(("courts", self.list_type, self.list_date))
        return aphc_parsers.parse_court_list(fixture_text("hcdbs/courtlist_b64.txt"))

    def court_list(self, court_no):
        self.owner.calls.append(("court_list", self.list_type, self.list_date, court_no))
        if self.owner.fail_with:
            raise self.owner.fail_with
        return aphc_parsers.parse_court_cause_list(fixture_text("hcdbs/court_list.html"))


class FakeAphc:
    def __init__(self):
        self.calls = []
        self.fail_with = None
        self.pdf_bytes = b"%PDF-1.4\n% synthetic test pdf\n%%EOF"

    def session(self, list_type, list_date):
        return FakeSession(self, list_type, list_date)

    def list_dates(self, list_type):
        self.calls.append(("dates", list_type))
        if self.fail_with:
            raise self.fail_with
        return aphc_parsers.parse_list_dates(fixture_text("hcdbs/dates_D.txt"))

    def publication_board(self):
        self.calls.append(("board",))
        return aphc_parsers.parse_online_board(fixture_text("hcdbs/online_board.html"))

    def display_board(self):
        self.calls.append(("display",))
        if self.fail_with:
            raise self.fail_with
        return aphc_parsers.parse_display_text(fixture_text("hcdbs/displaytext.txt"))

    def download_pdf(self, path):
        self.calls.append(("pdf", path))
        return self.pdf_bytes, "Fri, 13 Nov 2026 14:37:36 GMT"

    def close(self):
        pass


class FakeLexika:
    def __init__(self):
        self.calls = []
        self.fail_with = None
        self.return_identity: CaseIdentity | None = None  # force a mismatch

    def case_status(self, identity: CaseIdentity) -> CaseStatusResult:
        self.calls.append(("case_status", identity.slash))
        if self.fail_with:
            raise self.fail_with
        _, sections = lx.parse_case_selection(fixture_text("lexika/op2_selection.html"))
        returned = self.return_identity or identity
        return CaseStatusResult(
            identity=returned,
            primary=lx.parse_primary_details(fixture_text("lexika/op3_primary.html")),
            vakalath=lx.parse_vakalath(fixture_text("lexika/op4_vakalath.html")),
            petitioners=lx.parse_parties(fixture_text("lexika/op5_petitioners.html"), "PETITIONER"),
            respondents=lx.parse_parties(fixture_text("lexika/op6_respondents.html"), "RESPONDENT"),
            available_sections=sections,
            section_status={"primary": "present", "vakalath": "present", "petitioners": "present",
                            "respondents": "present"},
            calls_made=6,
        )

    def advocate_lookup(self, code):
        self.calls.append(("lookup", code))
        if self.fail_with:
            raise self.fail_with
        if code == "12345":
            return lx.parse_advocate_lookup(fixture_text("lexika/advocate_lookup.html"), code)
        if code == "67890":
            return lx.AdvocateLookup(advocate_code="67890", name="ADVOCATE TWO", available_dates=[])
        return lx.parse_advocate_lookup(fixture_text("lexika/advocate_not_found.html"), code)

    def advocate_cause_list(self, code, list_date):
        self.calls.append(("advocate_list", code, list_date))
        if self.fail_with:
            raise self.fail_with
        lookup = self.advocate_lookup(code)
        if list_date not in lookup.available_dates:
            return lookup, []
        return lookup, lx.parse_advocate_cause_list(fixture_text("lexika/advocate_list.html"))


@pytest.fixture
def fake_aphc(monkeypatch):
    fake = FakeAphc()
    monkeypatch.setattr(sources, "aphc_client", lambda: fake)
    return fake


@pytest.fixture
def fake_lexika(monkeypatch):
    fake = FakeLexika()
    monkeypatch.setattr(sources, "lexika_client", lambda: fake)
    return fake


@pytest.fixture
def client(engine, fake_aphc, fake_lexika):
    from app.main import app

    with TestClient(app) as c:
        yield c


def login(client: TestClient, code: str = "12345", email: str = "adv.one@example.com",
          sub: str | None = None) -> dict:
    """Google sign-in (step 1) + advocate-code link (step 2) - or step 1 only when already linked."""
    sub = sub or f"google-sub-{code}"
    r = client.post("/api/v1/auth/google", json={"id_token": fake_google_token(sub, email)})
    assert r.status_code == 200, r.text
    body = r.json()
    if body["status"] == "advocate_code_required":
        r = client.post("/api/v1/auth/google/link", json={"link_token": body["link_token"], "advocate_code": code})
        assert r.status_code == 200, r.text
        body = r.json()
    assert body["status"] == "signed_in", body
    return {"Authorization": f"Bearer {body['access_token']}", "_refresh": body["refresh_token"]}


def auth(headers: dict) -> dict:
    return {k: v for k, v in headers.items() if not k.startswith("_")}


@pytest.fixture
def user_headers(client):
    return auth(login(client))


@pytest.fixture
def admin_headers(client, engine):
    h = login(client, code="67890", email="adv.two@example.com")
    from sqlalchemy import select, update

    from app.models import AdvocateProfile, User

    with engine.begin() as conn:
        conn.execute(update(User).values(role="admin").where(User.id.in_(
            select(AdvocateProfile.user_id).where(AdvocateProfile.advocate_code == "67890"))))
    return auth(h)
