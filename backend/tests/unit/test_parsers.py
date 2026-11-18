from datetime import date

import pytest

from app.integrations.aphc import parsers as ap
from app.integrations.http import UpstreamNotFound, UpstreamParseError
from app.integrations.lexika import parsers as lx
from app.integrations.lexika.normaliser import normalise_primary
from tests.conftest import fixture_text


# ------------------------------------------------------------------ Hcdbs
def test_list_dates():
    assert ap.parse_list_dates(fixture_text("hcdbs/dates_D.txt"))[0] == date(2026, 11, 18)
    assert ap.parse_list_dates(" 0 ") == []
    with pytest.raises(UpstreamParseError):
        ap.parse_list_dates("2")
    with pytest.raises(UpstreamParseError):
        ap.parse_list_dates("<html>oops</html>")


def test_court_list_base64_json():
    courts = ap.parse_court_list(fixture_text("hcdbs/courtlist_b64.txt"))
    assert [c.court_no for c in courts] == ["1", "3"]
    with pytest.raises(UpstreamParseError):
        ap.parse_court_list("4")
    with pytest.raises(UpstreamParseError):
        ap.parse_court_list("not-base64!!")


def test_court_cause_list_structure_and_order():
    parsed = ap.parse_court_cause_list(fixture_text("hcdbs/court_list.html"))
    assert parsed.court_label == "COURT NO. 3"
    assert parsed.bench == "THE HONOURABLE SMT JUSTICE SAMPLE JUDGE"
    assert "(CAUSE LIST MOTION HEARING)" in parsed.headings and "(ADJOURNED MOTION LIST)" in parsed.headings
    assert [i.item_no for i in parsed.items] == ["1", "2", "59", "59.1"]  # original sequence preserved
    assert [i.sequence for i in parsed.items] == [1, 2, 3, 4]
    first = parsed.items[0]
    assert first.case_display == "WP/11111/2026"
    assert [(a.number, a.description) for a in first.applications] == [
        ("IA 1/2026", "Direction Petition"), ("IA 2/2026", "Implead Petition")]
    assert first.petitioner == "PETITIONER ALPHA" and first.respondent == "THE STATE OF ANDHRA PRADESH"
    assert first.respondent_advocates == ["GP FOR REVENUE", "ADVOCATE TWO"]
    assert first.list_section == "CAUSE LIST MOTION HEARING" and first.stage == "ADMISSION (OTHER SUBJECTS)"
    assert parsed.items[1].case_display == "WP(PIL)/22/2025"
    assert parsed.items[2].list_section == "ADJOURNED MOTION LIST" and parsed.items[2].district == "VISAKHAPATNAM"
    assert parsed.items[3].remarks == "59.1 along with 59"


def test_court_cause_list_layout_change_is_a_parser_failure():
    with pytest.raises(UpstreamParseError):
        ap.parse_court_cause_list("<html><body><table id='other'></table></body></html>")


def test_online_board_drops_vc_credentials():
    board = ap.parse_online_board(fixture_text("hcdbs/online_board.html"))
    assert board.list_date == date(2026, 11, 18)
    assert [r.court_no for r in board.rows] == ["1", "17", "3"]
    assert board.rows[0].status == "UPLOADED" and board.rows[0].pdf_path == "/Hcdbs/upload/court1_20261118.pdf"
    assert board.rows[1].status == "ON LEAVE" and board.rows[1].pdf_path is None
    flat = repr(board)
    assert "FAKEPC1" not in flat and "000-000-000-001" not in flat and "teams" not in flat


def test_display_text_states():
    rows = {r.court_no: r for r in ap.parse_display_text(fixture_text("hcdbs/displaytext.txt"))}
    assert rows["1"].state == "in_progress" and rows["1"].current_item == "D-52"
    assert rows["1"].kept_back == "1" and rows["1"].pending_serials == ["1", "37"] and rows["1"].coram == "DB-I"
    assert rows["21"].state == "not_in_session" and rows["21"].current_item is None
    assert rows["3"].state == "session_started"
    assert rows["7"].current_item == "P23"
    assert ap.parse_display_text("   ") == []
    with pytest.raises(UpstreamParseError):
        ap.parse_display_text("garbage@data")


# ------------------------------------------------------------------ Lexika
def test_case_type_options_are_read_from_source():
    m = lx.parse_case_type_options(fixture_text("lexika/op1_case_types.html"))
    assert m["WP"] == "WP-63" and m["WP(PIL)"] == "WP(PIL)-64"
    with pytest.raises(UpstreamParseError):
        lx.parse_case_type_options("<li>no select</li>")


def test_case_selection_identity_and_sections():
    identity, sections = lx.parse_case_selection(fixture_text("lexika/op2_selection.html"))
    assert identity.slash == "WP/11111/2026"
    assert "Case Vakalath Details" in sections and not any("Back to" in s for s in sections)


def test_primary_details_and_normaliser():
    sections = lx.parse_primary_details(fixture_text("lexika/op3_primary.html"))
    assert sections["PRIMARY DETAILS"]["Main Number"] == "WP 11111/2026"
    cols, extra = normalise_primary(sections)
    assert cols["filing_date"] == date(2026, 10, 26) and cols["listing_date"] == date(2026, 11, 18)
    assert cols["disposal_date"] is None and cols["disposal_type"] is None  # "-" means absent
    assert cols["judges"].endswith("SAMPLE JUDGE") and cols["sub_category"] == "MISCELLANEOUS MATTERS"
    assert extra == {}


def test_unknown_primary_labels_are_kept_not_dropped():
    cols, extra = normalise_primary({"PRIMARY DETAILS": {"Brand New Label": "X"}})
    assert cols == {} and extra == {"PRIMARY DETAILS / Brand New Label": "X"}


def test_vakalath_with_codes():
    v = lx.parse_vakalath(fixture_text("lexika/op4_vakalath.html"))
    assert (v[0].side, v[0].party_no, v[0].advocate_name, v[0].advocate_code) == ("P", "1", "ADVOCATE ONE", "12345")
    assert v[1].side == "R" and v[1].advocate_code == "67890"


def test_parties():
    p = lx.parse_parties(fixture_text("lexika/op5_petitioners.html"), "PETITIONER")
    r = lx.parse_parties(fixture_text("lexika/op6_respondents.html"), "RESPONDENT")
    assert [(x.party_no, x.name) for x in p] == [(1, "PETITIONER ALPHA")]
    assert [x.party_no for x in r] == [1, 2] and r[1].description == "Sample District."
    with pytest.raises(UpstreamParseError):
        lx.parse_parties(fixture_text("lexika/op5_petitioners.html"), "RESPONDENT")


def test_advocate_lookup_and_not_found():
    a = lx.parse_advocate_lookup(fixture_text("lexika/advocate_lookup.html"), "12345")
    assert a.name == "ADVOCATE ONE" and a.available_dates == [date(2026, 11, 20), date(2026, 11, 18)]
    with pytest.raises(UpstreamNotFound):
        lx.parse_advocate_lookup(fixture_text("lexika/advocate_not_found.html"), "99999999")


def test_advocate_cause_list_rows():
    rows = lx.parse_advocate_cause_list(fixture_text("lexika/advocate_list.html"))
    assert [(r.item_no, r.court_no) for r in rows] == [("1", "3"), ("28.1", "1"), ("59", "18")]
    assert rows[2].matter.main_case.slash == "CMA/506/2012" and rows[2].matter.application.slash == "IA/1/2026"
