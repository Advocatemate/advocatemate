"""LexikaClient against a mocked chatbot.php - verifies the exact six-operation contract."""

from datetime import date
from urllib.parse import parse_qs

import httpx
import pytest
import respx

from app.integrations.http import UpstreamIdentityMismatch, UpstreamProtocolError, UpstreamUnavailable
from app.integrations.lexika.client import LexikaClient
from app.utils.case_identity import CaseIdentity
from tests.conftest import fixture_text

BASE = "https://aphc.gov.in"


def _factory():
    return httpx.Client(base_url=BASE, follow_redirects=False, timeout=5)


def _router(responses: dict, seen: list, *, cookie: bool = True):
    def handler(request: httpx.Request):
        form = {k: v[0] for k, v in parse_qs(request.content.decode()).items()}
        seen.append((form, request.headers.get("cookie")))
        for key, resp in responses.items():
            k, v = key
            if form.get(k) == v:
                headers = {"set-cookie": "PHPSESSID=abc; path=/"} if cookie and len(seen) == 1 else {}
                return httpx.Response(200, text=resp, headers=headers)
        return httpx.Response(200, text="")

    return handler


SIX = {
    ("case_status_main", "Case Status"): fixture_text("lexika/op1_case_types.html"),
    ("main_case_type", "WP-63"): fixture_text("lexika/op2_selection.html"),
    ("case_status_query", "Case Primary Details"): fixture_text("lexika/op3_primary.html"),
    ("case_status_query", "Case Vakalath Details"): fixture_text("lexika/op4_vakalath.html"),
    ("case_status_query", "Case Petitioners Details"): fixture_text("lexika/op5_petitioners.html"),
    ("case_status_query", "Case Respondents Details"): fixture_text("lexika/op6_respondents.html"),
}


@respx.mock
def test_six_operations_in_order_with_one_session():
    seen = []
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(SIX, seen))
    result = LexikaClient(_factory).case_status(CaseIdentity.parse("WP/11111/2026"))
    forms = [f for f, _ in seen]
    assert forms == [
        {"case_status_main": "Case Status"},
        {"main_case_type": "WP-63", "case_no": "11111", "case_year": "2026"},
        {"case_status_query": "Case Primary Details"},
        {"case_status_query": "Case Vakalath Details"},
        {"case_status_query": "Case Petitioners Details"},
        {"case_status_query": "Case Respondents Details"},
    ]
    # Session continuity: every call after the first carries the PHP session cookie.
    assert all(c and "PHPSESSID=abc" in c for _, c in seen[1:])
    assert result.calls_made == 6
    assert result.section_status == {"primary": "present", "vakalath": "present", "petitioners": "present",
                                     "respondents": "present"}
    assert len(result.respondents) == 2 and result.vakalath[0].advocate_code == "12345"


@respx.mock
def test_identity_mismatch_is_rejected_before_detail_calls():
    seen = []
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(SIX, seen))
    with pytest.raises(UpstreamIdentityMismatch):
        LexikaClient(_factory).case_status(CaseIdentity.parse("WP/99999/2026"))  # op2 fixture says 11111
    assert len(seen) == 2


@respx.mock
def test_unknown_case_type_stops_after_transition():
    seen = []
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(SIX, seen))
    from app.integrations.http import UpstreamNotFound

    with pytest.raises(UpstreamNotFound):
        LexikaClient(_factory).case_status(CaseIdentity.parse("ZZZ/1/2026"))
    assert len(seen) == 1


@respx.mock
def test_partial_response_marks_section_without_corrupting_others():
    responses = dict(SIX)
    responses[("case_status_query", "Case Vakalath Details")] = "<li id='other'>unexpected</li>"
    seen = []
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(responses, seen))
    result = LexikaClient(_factory).case_status(CaseIdentity.parse("WP/11111/2026"))
    assert result.section_status["vakalath"] == "parse_failed"
    assert result.section_status["petitioners"] == "present" and result.vakalath == []


@respx.mock
def test_redirect_is_not_followed():
    respx.post(f"{BASE}/chatbot.php").mock(return_value=httpx.Response(302, headers={"location": "/login"}))
    with pytest.raises(UpstreamProtocolError):
        LexikaClient(_factory).case_status(CaseIdentity.parse("WP/11111/2026"))


@respx.mock
def test_server_error_is_classified_and_not_retried():
    route = respx.post(f"{BASE}/chatbot.php").mock(return_value=httpx.Response(500))
    with pytest.raises(UpstreamUnavailable):
        LexikaClient(_factory).case_status(CaseIdentity.parse("WP/11111/2026"))
    assert route.call_count == 1


def test_call_cap_enforced(monkeypatch):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "lexika_max_calls_per_case", 3)
    with respx.mock:
        seen = []
        respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(SIX, seen))
        with pytest.raises(UpstreamProtocolError):
            LexikaClient(_factory).case_status(CaseIdentity.parse("WP/11111/2026"))
        assert len(seen) == 3


@respx.mock
def test_advocate_cause_list_flow():
    seen = []
    responses = {
        ("query", "Advocate Code Wise Search"): "",
        ("chat_input", "12345"): fixture_text("lexika/advocate_lookup.html"),
        ("query", "18-11-2026"): fixture_text("lexika/advocate_list.html"),
    }
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(responses, seen))
    lookup, rows = LexikaClient(_factory).advocate_cause_list("12345", date(2026, 11, 18))
    assert [f for f, _ in seen] == [{"query": "Advocate Code Wise Search"}, {"chat_input": "12345"},
                                    {"query": "18-11-2026"}]
    assert lookup.name == "ADVOCATE ONE" and len(rows) == 3


@respx.mock
def test_advocate_date_not_offered_skips_list_call():
    seen = []
    responses = {("chat_input", "12345"): fixture_text("lexika/advocate_lookup.html")}
    respx.post(f"{BASE}/chatbot.php").mock(side_effect=_router(responses, seen))
    _, rows = LexikaClient(_factory).advocate_cause_list("12345", date(2026, 1, 1))
    assert rows == [] and len(seen) == 2


def test_advocate_code_validation():
    with pytest.raises(ValueError):
        LexikaClient(_factory).advocate_lookup("12a; DROP")
