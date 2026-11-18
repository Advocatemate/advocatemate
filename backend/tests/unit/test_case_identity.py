import pytest

from app.utils.case_identity import CaseIdentity, InvalidCaseIdentity, parse_listed_matter, same_case


def test_compact_and_slash_examples_from_handover():
    c = CaseIdentity.parse_compact("WP321152023")
    s = CaseIdentity.parse_slash("WP/32115/2023")
    assert c == s
    assert s.compact == "WP321152023"
    assert c.slash == "WP/32115/2023"
    assert s.display == "WP 32115/2023"


@pytest.mark.parametrize("value", ["WP/32115/2023", " wp / 32115 / 2023 ", "WP 32115/2023", "WP321152023"])
def test_parse_accepts_all_confirmed_forms(value):
    assert CaseIdentity.parse(value).canonical == "WP/32115/2023"


def test_bracketed_case_types_round_trip():
    i = CaseIdentity.parse_slash("WP(PIL)/206/2024")
    assert i.case_type == "WP(PIL)"
    assert CaseIdentity.parse_compact(i.compact) == i


@pytest.mark.parametrize(
    "value",
    ["", "WP", "WP/abc/2023", "WP/123/23", "WP/123/20234", "1WP/12/2023", "WP/012/2023", "WP//2023",
     "WP/123456789/2023", "WP/12/1800"],
)
def test_rejects_malformed_or_ambiguous(value):
    with pytest.raises(InvalidCaseIdentity):
        CaseIdentity.parse(value)


def test_leading_zero_is_not_silently_merged():
    with pytest.raises(InvalidCaseIdentity):
        CaseIdentity.build("WP", "0321", 2023)


def test_structured_fields_preserved():
    i = CaseIdentity.build(" crlp ", 7556, "2026")
    assert (i.case_type, i.number, i.year) == ("CRLP", "7556", 2026)


def test_same_case_is_structural_not_fuzzy():
    a = CaseIdentity.parse("WP/1234/2023")
    assert same_case(a, CaseIdentity.parse("WP 1234/2023"))
    assert not same_case(a, CaseIdentity.parse("WP/1234/2022"))
    assert not same_case(a, CaseIdentity.parse("WP(PIL)/1234/2023"))
    assert not same_case(a, CaseIdentity.parse("WP/12340/2023"))


def test_listed_matter_main_case():
    m = parse_listed_matter("CRLP/6552/2026")
    assert m.main_case.slash == "CRLP/6552/2026" and m.application is None


def test_listed_matter_application_row_from_lexika():
    m = parse_listed_matter("IA/1/2026-Condone Delay Petition,CMA/506/2012")
    assert m.main_case.slash == "CMA/506/2012"
    assert m.application.slash == "IA/1/2026"
    assert m.application_description == "Condone Delay Petition"
