"""Import the authoritative advocate registry (advocate_registry table).

Input rows: advocate_code, full_name, email (may be blank), status, [source_reference].
* Validates every row; invalid rows are reported and skipped, never half-imported.
* Inserts new codes, updates changed ones, reports unchanged ones.
* Codes absent from a full import are set to ``inactive`` (they lose access) unless keep_missing.
* Never touches the public ``advocates`` directory or any advocate profile / Google link.
* dry_run computes the same report and rolls back.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from email_validator import EmailNotValidError, validate_email
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.base import utcnow
from app.models import AdvocateRegistryEntry
from app.services import audit

STATUSES = {"active", "inactive", "suspended", "struck_off", "deceased", "retired"}


@dataclass
class ImportReport:
    added: list[str] = field(default_factory=list)
    updated: list[str] = field(default_factory=list)
    unchanged: list[str] = field(default_factory=list)
    deactivated: list[str] = field(default_factory=list)
    invalid: list[tuple[int, str]] = field(default_factory=list)  # (line, reason)
    dry_run: bool = False

    def summary(self) -> dict:
        return {"added": len(self.added), "updated": len(self.updated), "unchanged": len(self.unchanged),
                "deactivated": len(self.deactivated), "invalid": len(self.invalid), "dry_run": self.dry_run}


class RegistryImportError(ValueError):
    pass


def normalise_email(raw: str | None) -> str | None:
    value = (raw or "").strip()
    if not value:
        return None
    try:
        return validate_email(value, check_deliverability=False).normalized.lower()
    except EmailNotValidError as e:
        raise ValueError(f"invalid email: {e}") from e


def _validate(line: int, row: dict) -> tuple[str, dict] | tuple[None, str]:
    code = (row.get("advocate_code") or "").strip()
    if not code.isdigit() or not 1 <= len(code) <= 8:
        return None, f"line {line}: advocate_code must be 1-8 digits"
    name = " ".join((row.get("full_name") or "").split())
    if not name:
        return None, f"line {line}: full_name is required"
    status = (row.get("status") or "").strip().lower()
    if status not in STATUSES:
        return None, f"line {line}: status must be one of {sorted(STATUSES)}"
    try:
        email = normalise_email(row.get("email"))
    except ValueError as e:
        return None, f"line {line}: {e}"
    ref = (row.get("source_reference") or "").strip()[:128] or None
    return code, {"full_name": name[:255], "email_normalized": email, "status": status, "source_reference": ref}


def import_rows(db: Session, rows: list[dict], *, source: str, keep_missing: bool = False,
                dry_run: bool = False) -> ImportReport:
    report = ImportReport(dry_run=dry_run)
    seen: dict[str, dict] = {}
    for i, row in enumerate(rows, start=2):  # line 1 is the CSV header
        code, data = _validate(i, row)
        if code is None:
            report.invalid.append((i, data))
            continue
        if code in seen:
            report.invalid.append((i, f"line {i}: duplicate advocate_code {code}"))
            continue
        seen[code] = data
    if not seen:
        raise RegistryImportError("No valid registry rows - nothing imported (refusing to deactivate everyone).")

    now = utcnow()
    existing = {e.advocate_code: e for e in db.scalars(select(AdvocateRegistryEntry).with_for_update())}
    for code, data in seen.items():
        entry = existing.get(code)
        if entry is None:
            db.add(AdvocateRegistryEntry(advocate_code=code, source=source[:64], imported_at=now, **data))
            report.added.append(code)
            continue
        changed = any(getattr(entry, k) != v for k, v in data.items())
        if changed:
            for k, v in data.items():
                setattr(entry, k, v)
            entry.source = source[:64]
            entry.imported_at = now
            report.updated.append(code)
        else:
            report.unchanged.append(code)
    if not keep_missing:
        for code, entry in existing.items():
            if code not in seen and entry.status != "inactive":
                entry.status = "inactive"
                entry.imported_at = now
                report.deactivated.append(code)

    if dry_run:
        db.rollback()
    else:
        audit.record(db, "registry_import", target_type="registry", target_id=source[:64], **report.summary())
        db.flush()
    return report
