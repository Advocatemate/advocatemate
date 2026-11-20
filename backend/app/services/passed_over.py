"""Passed-over list: items a court kept back, from "Kept Back Cases" on the APHC display board.

Source (verified 20-11-2026): ``displaytext.jsp`` field 4 is rendered by APHC's own board as
"KEPT BACK CASES" and field 5 as its tooltip "Pending S.No". Both hold item serial numbers. Each
display-board poll records what the board shows, so the list covers only what AdvocateMate observed
while polling; it cannot be rebuilt for times it did not poll.

Note: APHC's cause-list list type "P" is the *Date Wise* cause list, not a passed-over list.
"""

from __future__ import annotations

import logging
import re
from datetime import date, datetime
from zoneinfo import ZoneInfo

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.base import as_utc, utcnow
from app.models import CauseList, Court, PassedOverItem

logger = logging.getLogger(__name__)

IST = ZoneInfo("Asia/Kolkata")
SOURCE = "aphc.gov.in display board (Kept Back Cases)"
_ITEM_RE = re.compile(r"^\d{1,4}(\.\d{1,3})?$")
_PREFIX_LIST_TYPE = {"D": "D", "S": "S"}  # board item prefix -> cause-list type


def court_date(moment: datetime | None = None) -> date:
    return as_utc(moment or utcnow()).astimezone(IST).date()


def parse_item_numbers(text: str | None) -> list[str] | None:
    """'15' / '15,22' / '15, 22.1' -> item numbers; None when the text is not a list of item numbers."""
    if not text or not text.strip():
        return []
    parts = [p for p in re.split(r"[,\s]+", text.strip()) if p]
    if not all(_ITEM_RE.match(p) for p in parts):
        return None
    return list(dict.fromkeys(parts))


def _field(row, name: str):
    return row.get(name) if isinstance(row, dict) else getattr(row, name)


def record_board(db: Session, rows, observed_at: datetime | None = None) -> dict:
    """Store the kept-back items shown on one display-board snapshot."""
    now = as_utc(observed_at or utcnow())
    list_date = court_date(now)
    kept_total, skipped = 0, []
    for row in rows:
        court_no = str(_field(row, "court_no"))
        current = _field(row, "current_item")
        if _field(row, "state") != "in_progress" or not current:
            continue  # the board shows no kept-back column for courts not in session
        # Kept-back numbers refer to the court's daily list unless the board shows a supplementary item.
        prefix = "S" if current.upper().startswith("S-") else "D"
        shown = parse_item_numbers(_field(row, "kept_back"))
        pending_list = parse_item_numbers(",".join(_field(row, "pending_serials") or []))
        if shown is None or pending_list is None:
            skipped.append(court_no)
            logger.info("kept-back text not understood for court %s; not recorded", court_no)
            continue
        # The "Kept Back Cases" cell and its "Pending S.No" tooltip can list different numbers
        # (e.g. cell "9", tooltip "9,10,15"): every number in either is a passed-over item.
        kept = list(dict.fromkeys(shown + pending_list))
        pending = set(pending_list)
        existing = {
            o.item_no: o
            for o in db.scalars(
                select(PassedOverItem).where(
                    PassedOverItem.list_date == list_date,
                    PassedOverItem.court_no == court_no,
                    PassedOverItem.list_prefix == prefix,
                )
            )
        }
        for item_no in kept:
            o = existing.get(item_no)
            if o is None:
                o = PassedOverItem(list_date=list_date, court_no=court_no, list_prefix=prefix, item_no=item_no,
                                   first_seen_at=now)
                db.add(o)
            o.last_seen_at = now
            o.removed_at = None
            o.pending = item_no in pending
            if o.pending:
                o.last_pending_at = now
            kept_total += 1
        for item_no, o in existing.items():
            if item_no not in kept and o.removed_at is None:
                o.removed_at = now
                o.pending = False
    db.flush()
    return {"list_date": list_date, "kept_back": kept_total, "skipped_courts": skipped}


def _status(o: PassedOverItem) -> str:
    if o.removed_at is not None:
        return "off_board"
    return "pending" if o.pending else "no_longer_pending"


def _item_sort_key(item_no: str) -> tuple:
    try:
        return (0, float(item_no))
    except ValueError:
        return (1, item_no)


def _court_items(db: Session, list_type: str, list_date: date, court_no: str, *, fetch: bool) -> dict[str, object]:
    """item_no -> first matching cause-list row for that court (fetching the list if allowed)."""
    from app.services import cause_lists  # local import: cause_lists is the heavier module

    cl = db.scalar(select(CauseList).where(CauseList.list_type == list_type, CauseList.list_date == list_date,
                                           CauseList.court_no == court_no))
    if cl is None and fetch:
        try:
            cause_lists.get_court_listing(db, list_type, list_date, court_no)
        except AppError as e:
            logger.info("cause list for passed-over court %s not available: %s", court_no, e.code)
        cl = db.scalar(select(CauseList).where(CauseList.list_type == list_type, CauseList.list_date == list_date,
                                               CauseList.court_no == court_no))
    out: dict[str, object] = {}
    for it in (cl.items if cl else []):
        out.setdefault(it.item_no, it)
    return out


def passed_over_list(db: Session, list_date: date | None = None, *, board: dict | None = None) -> dict:
    """Kept-back items for a date, grouped by court, with the matching cause-list case where known."""
    from app.services import cause_lists

    today = court_date()
    list_date = list_date or today
    observations = list(db.scalars(select(PassedOverItem).where(PassedOverItem.list_date == list_date)))
    dates = [d for (d,) in db.execute(
        select(PassedOverItem.list_date).group_by(PassedOverItem.list_date)
        .order_by(PassedOverItem.list_date.desc()).limit(30)
    )]
    board_rows = {str(r["court_no"]): r for r in (board or {}).get("courts", [])} if list_date == today else {}

    by_court: dict[str, list[PassedOverItem]] = {}
    for o in observations:
        by_court.setdefault(o.court_no, []).append(o)

    courts = []
    for court_no in sorted(by_court, key=lambda c: int(c) if c.isdigit() else 9999):
        rows = sorted(by_court[court_no], key=lambda o: (o.list_prefix, _item_sort_key(o.item_no)))
        lookups: dict[str, dict[str, object]] = {}
        items = []
        for o in rows:
            lt = _PREFIX_LIST_TYPE.get(o.list_prefix)
            if lt and lt not in lookups:
                lookups[lt] = _court_items(db, lt, list_date, court_no, fetch=list_date >= today)
            match = lookups.get(lt, {}).get(o.item_no) if lt else None
            items.append({
                "item_no": o.item_no,
                "list_prefix": o.list_prefix,
                "list_type": lt,
                "status": _status(o),
                "first_seen_at": as_utc(o.first_seen_at),
                "last_seen_at": as_utc(o.last_seen_at),
                "removed_at": as_utc(o.removed_at) if o.removed_at else None,
                "case": cause_lists.serialize_item(match) if match is not None else None,
            })
        board_row = board_rows.get(court_no) or {}
        court = db.get(Court, court_no)
        courts.append({
            "court_no": court_no,
            "coram": board_row.get("coram") or (court.coram if court else None),
            "current_item": board_row.get("current_item"),
            "pending": sum(1 for i in items if i["status"] == "pending"),
            "items": items,
        })

    first_seen = db.scalar(select(func.min(PassedOverItem.first_seen_at)).where(PassedOverItem.list_date == list_date))
    return {
        "list_date": list_date,
        "is_today": list_date == today,
        "source": SOURCE,
        "observed_from": as_utc(first_seen) if first_seen else None,
        "board_fetched_at": (board or {}).get("fetched_at") if list_date == today else None,
        "board_stale": (board or {}).get("stale") if list_date == today else None,
        "available_dates": dates,
        "total": sum(len(c["items"]) for c in courts),
        "pending": sum(c["pending"] for c in courts),
        "courts": courts,
        "note": "Items the court kept back (passed over), as shown on the APHC display board while "
                "AdvocateMate was checking it. Always confirm with the court.",
    }
