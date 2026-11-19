"""Advocate registry import: validation, normalisation, deactivation, dry runs, and isolation."""

import subprocess
import sys
from pathlib import Path

import pytest
from sqlalchemy import select

from app.db.session import db_session
from app.models import Advocate, AdvocateRegistryEntry
from app.services.registry import RegistryImportError, import_rows

ROW = {"advocate_code": "55555", "full_name": "  NEW   ADVOCATE ", "email": " New.Adv@Example.COM ", "status": "Active"}


def registry() -> dict:
    with db_session() as db:
        return {e.advocate_code: (e.full_name, e.email_normalized, e.status)
                for e in db.scalars(select(AdvocateRegistryEntry))}


def test_sample_registry_loaded_by_fixture():
    r = registry()
    assert r["12345"] == ("ADVOCATE ONE", "adv.one@example.com", "active")  # email lower-cased
    assert r["22222"][1] is None and r["11111"][2] == "inactive"


def test_add_update_unchanged_and_deactivate_missing():
    rows = [ROW, {"advocate_code": "12345", "full_name": "ADVOCATE ONE", "email": "adv.one@example.com",
                  "status": "active", "source_reference": "SAMPLE-0001"},
            {"advocate_code": "67890", "full_name": "ADVOCATE TWO", "email": "new.two@example.com", "status": "active"}]
    with db_session() as db:
        rep = import_rows(db, rows, source="t")
    assert rep.added == ["55555"] and rep.updated == ["67890"] and rep.unchanged == ["12345"]
    assert set(rep.deactivated) == {"24680", "22222", "33333"}  # 11111 was already inactive
    r = registry()
    assert r["55555"] == ("NEW ADVOCATE", "new.adv@example.com", "active")
    assert r["67890"][1] == "new.two@example.com" and r["24680"][2] == "inactive"


def test_keep_missing():
    with db_session() as db:
        rep = import_rows(db, [ROW], source="t", keep_missing=True)
    assert rep.deactivated == [] and registry()["24680"][2] == "active"


def test_invalid_and_duplicate_rows_skipped():
    rows = [ROW, dict(ROW), {"advocate_code": "12a", "full_name": "X", "email": "", "status": "active"},
            {"advocate_code": "1", "full_name": "", "email": "", "status": "active"},
            {"advocate_code": "2", "full_name": "Y", "email": "not-an-email", "status": "active"},
            {"advocate_code": "3", "full_name": "Z", "email": "", "status": "pending"}]
    with db_session() as db:
        rep = import_rows(db, rows, source="t", keep_missing=True)
    reasons = " | ".join(r for _, r in rep.invalid)
    assert rep.added == ["55555"] and len(rep.invalid) == 5
    for needle in ("duplicate", "1-8 digits", "full_name", "invalid email", "status must be"):
        assert needle in reasons


def test_dry_run_changes_nothing():
    before = registry()
    with db_session() as db:
        rep = import_rows(db, [ROW], source="t", dry_run=True)
    assert rep.added == ["55555"] and rep.dry_run
    assert registry() == before


def test_refuses_empty_import():
    with db_session() as db, pytest.raises(RegistryImportError):
        import_rows(db, [{"advocate_code": "x"}], source="t")
    assert registry()["12345"][2] == "active"


def test_never_touches_public_directory():
    with db_session() as db:
        db.add(Advocate(advocate_code="12345", name="NAME FROM LEXIKA", source="aphc_lexika_chatbot"))
    with db_session() as db:
        import_rows(db, [ROW], source="t", keep_missing=True)
    with db_session() as db:
        assert db.get(Advocate, "12345").name == "NAME FROM LEXIKA"


def test_cli_dry_run(tmp_path: Path):
    csv_path = tmp_path / "reg.csv"
    csv_path.write_text("advocate_code,full_name,email,status\n55555,NEW ADVOCATE,new@example.com,active\n",
                        encoding="utf-8")
    backend = Path(__file__).resolve().parents[2]
    args = [sys.executable, "-m", "scripts.import_registry", str(csv_path), "--source", "cli-test", "--dry-run",
            "--keep-missing"]
    out = subprocess.run(args, cwd=backend, capture_output=True, text=True, timeout=120)  # noqa: S603 - fixed args
    assert out.returncode == 0, out.stderr
    assert "DRY RUN" in out.stdout and "'added': 1" in out.stdout
