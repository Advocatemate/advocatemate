"""Assemble the case-details response from what the sources actually returned.

Fields are omitted (not nulled-in with guesses) when no source provided them.
"""

from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.base import as_utc
from app.models import (
    AdvocateCaseLink,
    Case,
    CauseList,
    CauseListItem,
    LexikaCaseParty,
    LexikaCaseVakalathMapping,
)
from app.services import enrichment


def _drop_empty(d: dict) -> dict:
    return {k: v for k, v in d.items() if v not in (None, "", [], {})}


def build(db: Session, case: Case, *, user_id: uuid.UUID | None = None, request_enrichment: bool = True) -> dict:
    if request_enrichment:
        enrichment.request_enrichment(db, case, user_id=user_id)
    row = enrichment.cache_row(db, case.id)

    identity = {
        "case_id": str(case.id),
        "case_type": case.case_type,
        "case_number": case.case_number,
        "case_year": case.case_year,
        "display": case.canonical_key,
    }
    information: dict = {}
    parties: dict = {}
    advocates: dict = {}
    additional: dict = {}
    if row is not None:
        identity.update(_drop_empty({"main_number": row.main_number, "sr_number": row.sr_number}))
        information = _drop_empty(
            {
                "status": row.status,
                "filing_date": row.filing_date,
                "registration_date": row.registration_date,
                "listing_date": row.listing_date,
                "disposal_date": row.disposal_date,
                "disposal_type": row.disposal_type,
                "purpose": row.purpose,
                "bench": row.judges,
                "case_category": row.case_category,
                "category": row.category,
                "sub_category": row.sub_category,
                "district": row.district,
            }
        )
        parties = _drop_empty(
            {
                "petitioner_summary": row.petitioner,
                "respondent_summary": row.respondent,
                "petitioners": [
                    _drop_empty({"party_no": p.party_no, "name": p.name, "description": p.description})
                    for p in db.scalars(
                        select(LexikaCaseParty)
                        .where(LexikaCaseParty.case_id == case.id, LexikaCaseParty.side == "P")
                        .order_by(LexikaCaseParty.party_no)
                    )
                ],
                "respondents": [
                    _drop_empty({"party_no": p.party_no, "name": p.name, "description": p.description})
                    for p in db.scalars(
                        select(LexikaCaseParty)
                        .where(LexikaCaseParty.case_id == case.id, LexikaCaseParty.side == "R")
                        .order_by(LexikaCaseParty.party_no)
                    )
                ],
            }
        )
        advocates = _drop_empty(
            {
                "petitioner_advocate": row.petitioner_advocate,
                "respondent_advocate": row.respondent_advocate,
                "vakalath": [
                    _drop_empty(
                        {
                            "side": v.side,
                            "party_no": v.party_no,
                            "advocate_name": v.advocate_name,
                            "advocate_code": v.advocate_code,
                        }
                    )
                    for v in db.scalars(
                        select(LexikaCaseVakalathMapping)
                        .where(LexikaCaseVakalathMapping.case_id == case.id)
                        .order_by(LexikaCaseVakalathMapping.side, LexikaCaseVakalathMapping.party_no)
                    )
                ],
            }
        )
        if row.extra_fields:
            additional["other_source_fields"] = row.extra_fields

    # Listing history we have observed in synced cause lists (newest first).
    listings = []
    for item, cl in db.execute(
        select(CauseListItem, CauseList)
        .join(CauseList, CauseList.id == CauseListItem.cause_list_id)
        .where(CauseListItem.case_id == case.id)
        .order_by(CauseList.list_date.desc())
        .limit(30)
    ):
        listings.append(
            _drop_empty(
                {
                    "list_date": cl.list_date,
                    "list_type": cl.list_type,
                    "court_no": cl.court_no,
                    "item_no": item.item_no,
                    "bench": cl.bench,
                    "stage": item.stage,
                    "applications": item.applications,
                }
            )
        )
        if "petitioner_summary" not in parties and item.petitioner:
            parties["petitioner_summary"] = item.petitioner
            parties["respondent_summary"] = item.respondent
            parties["summary_source"] = "cause_list"
    if listings:
        additional["observed_listings"] = listings
        apps = listings[0].get("applications")
        if apps:
            additional["applications_in_latest_listing"] = apps

    links = db.scalars(
        select(AdvocateCaseLink).where(AdvocateCaseLink.case_id == case.id).order_by(AdvocateCaseLink.list_date.desc())
    ).all()
    if links:
        advocates["listed_for_advocate_codes"] = sorted({link.advocate_code for link in links})

    unavailable = [
        "orders",
        "case_history",
        "connected_matters",
        "lower_court_details",
        "ia_details",
        "usr_details",
        "mp_details",
    ]
    return {
        "identity": identity,
        "information": information,
        "parties": parties,
        "advocates": advocates,
        "additional": additional,
        "enrichment": enrichment.status_payload(db, case),
        "provenance": {
            "source": row.source if row else None,
            "fetched_at": as_utc(row.fetched_at) if row else None,
            "client_version": row.client_version if row else None,
            "parser_version": row.parser_version if row else None,
            "sections": row.sections if row else {},
        },
        "unavailable_sections": unavailable,
        "unavailable_note": (
            "Orders, case history, IA/USR/MP and connected-matter details are not yet retrieved: "
            "their upstream contract has not been verified (see docs/APHC_INTEGRATION.md)."
        ),
    }
