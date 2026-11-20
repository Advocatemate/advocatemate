"""Passed-over list (display-board kept-back items) and court cause-list PDF checking / fallback."""

from datetime import date, timedelta

from sqlalchemy import select

from app.db.base import utcnow
from app.db.session import db_session
from app.integrations.http import UpstreamUnavailable
from app.models import CauseListPdfParse, PassedOverItem
from app.services import cause_list_pdfs, live_board, passed_over
from app.tasks import jobs
from tests.court_pdf_builder import fixture_court3_pdf

LIST = "/api/v1/cause-list/court/3?list_type=D&date=2026-11-18"


def _publish(client, user_headers):
    # The online-board fixture links court1/court3 PDFs for 2026-11-18.
    assert client.get("/api/v1/cause-list/status", headers=user_headers).status_code == 200


# ------------------------------------------------------------------ PDF check
def test_online_list_verified_against_official_pdf(client, user_headers, fake_aphc):
    fake_aphc.pdf_bytes = fixture_court3_pdf()
    _publish(client, user_headers)
    body = client.get(LIST, headers=user_headers).json()
    assert body["items_source"] == "online_list"
    v = body["pdf_verification"]
    assert v["status"] == "verified"
    assert (v["matched"], v["differs"], v["not_in_pdf"], v["pdf_only"]) == (4, 0, 0, 0)
    assert v["source_url"].endswith("/Hcdbs/upload/court3_20261118.pdf") and v["pdf_pages"] == 2
    assert [i["pdf_check"]["status"] for i in body["items"]] == ["match"] * 4
    # read once; the next request reuses the stored result
    pdf_calls = sum(1 for c in fake_aphc.calls if c[0] == "pdf")
    client.get(LIST, headers=user_headers)
    assert sum(1 for c in fake_aphc.calls if c[0] == "pdf") == pdf_calls


def test_differences_and_pdf_only_items_are_reported(client, user_headers, fake_aphc):
    fake_aphc.pdf_bytes = fixture_court3_pdf(item2_pet="SOMEONE ELSE", extra_item=True)
    _publish(client, user_headers)
    body = client.get(LIST, headers=user_headers).json()
    v = body["pdf_verification"]
    assert v["status"] == "differences"
    assert (v["matched"], v["differs"], v["pdf_only"]) == (3, 1, 1)
    assert v["pdf_only_items"][0]["case_number"] == "WP/555/2019"
    assert body["items"][1]["pdf_check"] == {"status": "differs", "fields": ["petitioner_advocates"]}
    # the online list itself is never overwritten by the PDF
    assert body["items"][1]["petitioner_advocates"] == ["ADVOCATE THREE"]


def test_unreadable_pdf_never_breaks_the_list(client, user_headers, fake_aphc):
    _publish(client, user_headers)  # default fake PDF bytes are not a real cause list
    body = client.get(LIST, headers=user_headers).json()
    assert len(body["items"]) == 4
    assert body["pdf_verification"]["status"] == "failed"
    assert body["pdf_verification"]["error_code"] == "parser_failure"
    assert all(i["pdf_check"] is None for i in body["items"])


def test_court_without_published_pdf(client, user_headers):
    body = client.get("/api/v1/cause-list/court/17?list_type=D&date=2026-11-18", headers=user_headers).json()
    assert body["pdf_verification"]["status"] == "not_available"


def test_weekly_lists_are_not_checked_against_court_pdfs(client, user_headers):
    body = client.get("/api/v1/cause-list/court/3?list_type=W&date=2026-11-18", headers=user_headers).json()
    assert body["pdf_verification"] is None


def test_pdf_fallback_when_online_list_is_unavailable(client, user_headers, fake_aphc):
    fake_aphc.pdf_bytes = fixture_court3_pdf()
    _publish(client, user_headers)
    fake_aphc.fail_with = UpstreamUnavailable("upstream_unavailable")
    r = client.get(LIST, headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["items_source"] == "official_pdf" and body["fallback_reason"] == "online_list_unavailable"
    assert "official court cause-list PDF" in body["source"]
    assert [i["case_number"] for i in body["items"]] == ["WP/11111/2026", "WP(PIL)/22/2025", "WP/333/2017",
                                                         "WP/444/2018"]
    assert body["items"][0]["pdf_pages"] == [1, 1]


def test_no_fallback_without_pdf_reports_the_failure(client, user_headers, fake_aphc):
    fake_aphc.fail_with = UpstreamUnavailable("upstream_unavailable")
    r = client.get("/api/v1/cause-list/court/17?list_type=D&date=2026-11-18", headers=user_headers)
    assert r.status_code == 502 and r.json()["error"]["code"] == "upstream_unavailable"


def test_background_job_reads_published_pdfs_once(client, user_headers, fake_aphc):
    fake_aphc.pdf_bytes = fixture_court3_pdf()
    _publish(client, user_headers)
    first = cause_list_pdfs.parse_published_pdfs(db_session)
    assert first["list_date"] == "2026-11-18" and first["parsed"] == 2 and first["failed"] == 0
    again = cause_list_pdfs.parse_published_pdfs(db_session)
    assert again["unchanged"] == 2 and again["parsed"] == 0
    with db_session() as db:
        rows = db.scalars(select(CauseListPdfParse).order_by(CauseListPdfParse.court_no)).all()
        assert [(r.court_no, r.status, r.item_count) for r in rows] == [("1", "parsed", 4), ("3", "parsed", 4)]


# ------------------------------------------------------------------ passed-over
def test_kept_back_numbers_are_parsed_strictly():
    assert passed_over.parse_item_numbers("15") == ["15"]
    assert passed_over.parse_item_numbers("9,10, 15 , 21.1") == ["9", "10", "15", "21.1"]
    assert passed_over.parse_item_numbers("") == [] and passed_over.parse_item_numbers(None) == []
    assert passed_over.parse_item_numbers("4 cases") is None


def test_board_poll_records_passed_over_items(client, user_headers, fake_aphc):
    with db_session() as db:
        live_board.poll_display_board(db)
    body = client.get("/api/v1/cause-list/passed-over", headers=user_headers).json()
    assert body["is_today"] is True and body["list_date"] == passed_over.court_date().isoformat()
    assert "Kept Back Cases" in body["source"]
    courts = {c["court_no"]: c for c in body["courts"]}
    # fixture: court 1 cell "1", tooltip "1,37"; court 11 cell "9", tooltip "9,10,15"; others none
    assert sorted(courts) == ["1", "11"]
    assert [(i["item_no"], i["status"]) for i in courts["1"]["items"]] == [("1", "pending"), ("37", "pending")]
    assert [i["item_no"] for i in courts["11"]["items"]] == ["9", "10", "15"]
    assert courts["1"]["current_item"] == "D-52" and courts["1"]["coram"] == "DB-I"
    # joined with the court's daily list: item 1 is WP/11111/2026 in the fixture list
    assert courts["1"]["items"][0]["case"]["case_number"] == "WP/11111/2026"
    assert courts["1"]["items"][1]["case"] is None  # item 37 is not in that list
    assert body["total"] == 5 and body["pending"] == 5
    assert body["available_dates"] == [passed_over.court_date().isoformat()]


def test_items_taken_up_or_removed_change_status():
    rows = [{"court_no": "11", "state": "in_progress", "current_item": "D-49", "kept_back": "9",
             "pending_serials": ["9", "10", "15"], "coram": "VSJ"}]
    now = utcnow()
    with db_session() as db:
        passed_over.record_board(db, rows, observed_at=now)
        rows[0].update(current_item="D-60", kept_back="9", pending_serials=["15"])
        passed_over.record_board(db, rows, observed_at=now + timedelta(minutes=5))
    with db_session() as db:
        got = {o.item_no: o for o in db.scalars(select(PassedOverItem))}
        assert (got["9"].pending, got["9"].removed_at) == (False, None)  # still kept back, not pending
        assert got["10"].removed_at is not None and got["10"].pending is False  # gone from the board
        assert got["15"].pending is True and got["15"].first_seen_at < got["15"].last_seen_at
        statuses = {i: passed_over._status(o) for i, o in got.items()}
        assert statuses == {"9": "no_longer_pending", "10": "off_board", "15": "pending"}
        # it comes back if the board lists it again
        rows[0].update(kept_back="10", pending_serials=["10"])
        passed_over.record_board(db, rows, observed_at=now + timedelta(minutes=10))
        assert passed_over._status(db.scalar(select(PassedOverItem).where(PassedOverItem.item_no == "10"))) == "pending"


def test_courts_not_in_session_and_unreadable_values_are_skipped():
    rows = [
        {"court_no": "21", "state": "not_in_session", "current_item": None, "kept_back": "4",
         "pending_serials": ["4"], "coram": None},
        {"court_no": "22", "state": "in_progress", "current_item": "D-5", "kept_back": "two cases",
         "pending_serials": [], "coram": None},
        {"court_no": "23", "state": "in_progress", "current_item": "S-3", "kept_back": "2",
         "pending_serials": ["2"], "coram": None},
    ]
    with db_session() as db:
        out = passed_over.record_board(db, rows)
        assert out["skipped_courts"] == ["22"] and out["kept_back"] == 1
        o = db.scalar(select(PassedOverItem))
        assert (o.court_no, o.list_prefix, o.item_no) == ("23", "S", "2")  # supplementary list item


def test_passed_over_for_a_date_without_records(client, user_headers):
    body = client.get("/api/v1/cause-list/passed-over?date=2026-11-02", headers=user_headers).json()
    assert body["courts"] == [] and body["total"] == 0 and body["is_today"] is False


def test_passed_over_requires_sign_in(client):
    assert client.get("/api/v1/cause-list/passed-over").status_code == 401


def test_housekeeping_removes_old_records():
    old = utcnow() - timedelta(days=200)
    with db_session() as db:
        db.add(PassedOverItem(list_date=date(2026, 5, 1), court_no="1", list_prefix="D", item_no="1",
                              first_seen_at=old, last_seen_at=old))
        db.add(CauseListPdfParse(list_type="D", list_date=date(2026, 5, 1), court_no="1", sha256="0" * 64,
                                 parser_version="x", status="parsed", parsed_at=old))
    r = jobs.housekeeping()
    assert r["passed_over"] == 1 and r["pdf_parses"] == 1
