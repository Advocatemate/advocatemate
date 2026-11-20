"""Court cause-list PDF parser, on synthetic PDFs in the APHC layout (fictional data)."""

import pytest

from app.integrations.aphc.pdf_parser import parse_court_pdf
from app.integrations.http import UpstreamParseError
from app.services.cause_list_pdfs import compare
from tests.court_pdf_builder import Item, Note, PageBreak, Section, Stage, build_court_pdf, fixture_court3_pdf


def parse(events):
    return parse_court_pdf(build_court_pdf(events))


def test_items_sections_stages_and_notes():
    r = parse_court_pdf(fixture_court3_pdf())
    p = r.parsed
    assert r.page_count == 2
    assert p.court_label == "COURT NO. 3"
    assert p.bench == "THE HONOURABLE SMT JUSTICE SAMPLE JUDGE"
    assert "(CAUSE LIST MOTION HEARING)" in p.headings and "(ADJOURNED MOTION LIST)" in p.headings
    assert [(i.sequence, i.item_no, i.case_display) for i in p.items] == [
        (1, "1", "WP/11111/2026"), (2, "2", "WP(PIL)/22/2025"), (3, "59", "WP/333/2017"), (4, "59.1", "WP/444/2018"),
    ]
    one = p.items[0]
    assert [(a.number, a.description) for a in one.applications] == [
        ("IA 1/2026", "Direction Petition"), ("IA 2/2026", "Implead Petition")]
    assert one.petitioner == "PETITIONER ALPHA" and one.respondent == "THE STATE OF ANDHRA PRADESH"
    assert one.petitioner_advocates == ["ADVOCATE ONE"]
    assert one.respondent_advocates == ["GP FOR REVENUE", "ADVOCATE TWO"]
    assert one.district == "GUNTUR"
    assert (one.list_section, one.stage) == ("CAUSE LIST MOTION HEARING", "ADMISSION (OTHER SUBJECTS)")
    gamma, delta = p.items[2], p.items[3]
    assert (gamma.list_section, gamma.stage) == ("ADJOURNED MOTION LIST", "ADMISSION (REVENUE)")
    assert gamma.applications[0].number == "IA 1/2017(WPMP 3456/2017)"  # rejoined across the line wrap
    assert delta.remarks == "59.1 along with 59"  # the grouping note belongs to the item that follows it
    assert r.item_pages == {1: (1, 1), 2: (1, 1), 3: (2, 2), 4: (2, 2)}


def test_page_numbers_are_not_items_or_text():
    p = parse_court_pdf(fixture_court3_pdf()).parsed
    assert all(not (i.district or "").endswith(("1", "2")) for i in p.items)


def test_item_continues_across_page_break_without_header():
    r = parse([
        Section("(DAILY LIST)"),
        Item("7", ["WP/7777/2026", "IA 1/2026", "Stay Petition"],
             ["LONG NAMED PETITIONER", "AND OTHERS", "Vs", " THE STATE OF ANDHRA", "PRADESH"],
             ["ADVOCATE SEVEN"], ["GP FOR REVENUE", "GP FOR FORESTS", "ADVOCATE EIGHT"], ["GUNTUR"],
             break_after=3),
        Item("8", ["WP/8888/2026"], ["PETITIONER EIGHT", "Vs", " RESPONDENT EIGHT"], ["ADVOCATE NINE"], [],
             ["KRISHNA"]),
    ])
    seven, eight = r.parsed.items
    assert seven.petitioner == "LONG NAMED PETITIONER AND OTHERS"
    assert seven.respondent == "THE STATE OF ANDHRA PRADESH"
    assert seven.respondent_advocates == ["GP FOR REVENUE", "GP FOR FORESTS", "ADVOCATE EIGHT"]
    assert r.item_pages[1] == (1, 2) and r.item_pages[2] == (2, 2)
    assert eight.list_section == "DAILY LIST"  # section carries over the page without a header


def test_table_shifted_on_a_later_page():
    r = parse([
        Section("(DAILY LIST)"),
        Item("9", ["WP/9999/2026"], ["PETITIONER NINE", "Vs", " RESPONDENT NINE"], ["ADVOCATE ONE"], [],
             ["GUNTUR"]),
        PageBreak(dx=-5.0),
        Item("10", ["WP/1010/2026"], ["PETITIONER TEN", "Vs", " RESPONDENT TEN"], ["ADVOCATE TWO"], [],
             ["KRISHNA"]),
        Item("11", ["WP/1111/2026"], ["PETITIONER ELEVEN", "Vs", " RESPONDENT ELEVEN"], ["ADVOCATE THREE"], [],
             ["GUNTUR"]),
    ])
    assert [(i.item_no, i.case_display) for i in r.parsed.items] == [
        ("9", "WP/9999/2026"), ("10", "WP/1010/2026"), ("11", "WP/1111/2026")]


def test_ia_printed_above_main_case_and_wrapped_case_number():
    p = parse([
        Section("(DAILY LIST)"),
        Item("78", ["IA/1/2024", "Restoration Petition", "AS/2168/2001"], ["PETITIONER", "Vs", " RESPONDENT"]),
        Item("124", ["MACMA/18030/2011/ (Filing", "No.)"], ["PETITIONER", "Vs", " RESPONDENT"]),
    ]).parsed
    assert p.items[0].case_display == "AS/2168/2001"
    assert [(a.number, a.description) for a in p.items[0].applications] == [("IA/1/2024", "Restoration Petition")]
    assert p.items[1].case_display == "MACMA/18030/2011/ (Filing No.)"


def test_word_overflowing_its_column_stays_in_its_cell():
    p = parse([
        Section("(DAILY LIST)"),
        Item("20", ["WP/2020/2026"], ["PETITIONER", "Vs", " RESPONDENT"], [],
             ["GP FOR REVENUE", "NAMRATHA CHOUDARYLONG P"], ["KURNOOL"]),
    ]).parsed
    assert p.items[0].respondent_advocates == ["GP FOR REVENUE", "NAMRATHA CHOUDARYLONG P"]
    assert p.items[0].district == "KURNOOL"


def test_wrapped_item_number_and_split_case_prefix():
    p = parse([
        Section("(DAILY LIST)"),
        Item("165", ["CC/1069/2019"], ["A", "Vs", " B"]),
        # "165.10" is too wide for the column: "165.1" on the first line, "0" on the second.
        Item("165.1", ["CC/295/2020", "(WP/30839/2011)"], ["C", "Vs", " D"], sno_wrap="0"),
        Item("328.2", ["X", "OBJ/18/2022", "(OP/385/2006)"], ["E", "Vs", " F"]),
        # a one-line case cell followed directly by the next item is NOT a wrapped number
        Item("21.5", ["WP/215/2026"], ["G", "Vs", " H"]),
        Item("22", ["WP/22/2026"], ["I", "Vs", " J"]),
    ]).parsed
    assert [(i.item_no, i.case_display) for i in p.items] == [
        ("165", "CC/1069/2019"), ("165.10", "CC/295/2020"), ("328.2", "X-OBJ/18/2022"),
        ("21.5", "WP/215/2026"), ("22", "WP/22/2026")]
    assert p.items[1].applications[0].description == "WP/30839/2011"


def test_numbering_restarts_in_a_later_section():
    p = parse([
        Section("(FRESH MOTION HEARING)"),
        Item("1", ["WA/1/2026"], ["A", "Vs", " B"]),
        Section("(CAUSE LIST MOTION HEARING)"),
        Stage("ADMISSION"),
        Item("1", ["ARBAPPL/2/2026"], ["C", "Vs", " D"]),
    ]).parsed
    assert [(i.sequence, i.item_no, i.list_section, i.stage) for i in p.items] == [
        (1, "1", "FRESH MOTION HEARING", None), (2, "1", "CAUSE LIST MOTION HEARING", "ADMISSION")]


def test_not_a_pdf_and_pdf_without_table_are_rejected():
    with pytest.raises(UpstreamParseError):
        parse_court_pdf(b"<html>not a pdf</html>")
    with pytest.raises(UpstreamParseError):
        parse_court_pdf(b"%PDF-1.4\n% synthetic test pdf\n%%EOF")
    with pytest.raises(UpstreamParseError):
        parse([Stage("NOTICE TO ADVOCATES"), Note("Lists will be published at 6 PM")])


# ------------------------------------------------------------------ comparison
def _online(seq, item_no, case, *, pet="A", res="B", pet_adv=("X",), res_adv=(), district="GUNTUR"):
    return {"sequence": seq, "item_no": item_no, "case_display": case, "petitioner": pet, "respondent": res,
            "petitioner_advocates": list(pet_adv), "respondent_advocates": list(res_adv), "district": district}


def test_compare_ignores_wrapping_case_and_punctuation():
    online = [_online(1, "1", "WP/1/2026", pet="K. VENUGOPAL REDDY", res_adv=["GP FOR LAW LEGISLATIVE AFFAIRS"])]
    pdf = [_online(1, "1", "wp/1/2026", pet="K.VENUGOPAL  REDDY", res_adv=["GP FOR LAW", "LEGISLATIVE AFFAIRS"])]
    r = compare(online, pdf)
    assert r["per_item"][1] == {"status": "match", "fields": []} and r["matched"] == 1


def test_compare_reports_differences_missing_and_pdf_only_items():
    online = [_online(1, "1", "WP/1/2026"), _online(2, "2", "WP/2/2026", pet_adv=["X", "EXTRA ADVOCATE"]),
              _online(3, "3", "WP/3/2026")]
    pdf = [_online(1, "1", "WP/1/2026"), _online(2, "2", "WP/2/2026"), _online(3, "4", "WP/4/2026")]
    r = compare(online, pdf)
    assert r["per_item"][2] == {"status": "differs", "fields": ["petitioner_advocates"]}
    assert r["per_item"][3] == {"status": "not_in_pdf", "fields": []}
    assert [p["item_no"] for p in r["pdf_only"]] == ["4"]
    assert (r["matched"], r["differs"], r["not_in_pdf"]) == (1, 1, 1)


def test_compare_keys_repeated_item_numbers_by_order():
    online = [_online(1, "1", "WA/1/2026"), _online(2, "1", "ARBAPPL/2/2026")]
    pdf = [_online(1, "1", "WA/1/2026"), _online(2, "1", "ARBAPPL/2/2026")]
    assert compare(online, pdf)["matched"] == 2
