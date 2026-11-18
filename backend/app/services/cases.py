from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.errors import AppError, NotFound
from app.models import Case
from app.utils.case_identity import CaseIdentity, InvalidCaseIdentity


def parse_identity_or_400(value: str) -> CaseIdentity:
    try:
        return CaseIdentity.parse(value)
    except InvalidCaseIdentity as e:
        raise AppError(
            "Case number must look like WP/32115/2023", code="invalid_case_number", status_code=422
        ) from e


def find_case(db: Session, identity: CaseIdentity) -> Case | None:
    return db.scalar(select(Case).where(Case.canonical_key == identity.canonical))


def get_or_create_case(db: Session, identity: CaseIdentity) -> Case:
    existing = find_case(db, identity)
    if existing:
        return existing
    case = Case(
        case_type=identity.case_type,
        case_number=identity.number,
        case_year=identity.year,
        canonical_key=identity.canonical,
        compact_key=identity.compact,
    )
    try:
        with db.begin_nested():
            db.add(case)
            db.flush()
    except IntegrityError:
        existing = find_case(db, identity)
        if existing is None:
            raise
        return existing
    return case


def get_case_or_404(db: Session, case_id: uuid.UUID) -> Case:
    case = db.get(Case, case_id)
    if case is None:
        raise NotFound("Case not found")
    return case


def identity_of(case: Case) -> CaseIdentity:
    return CaseIdentity.build(case.case_type, case.case_number, case.case_year)
