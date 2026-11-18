"""HcdbsSession request sequence against mocked aphc.gov.in."""

from datetime import date
from urllib.parse import parse_qs

import httpx
import pytest
import respx

from app.integrations.aphc.client import AphcClient, HcdbsSession
from app.integrations.http import UpstreamBlocked, UpstreamProtocolError
from tests.conftest import fixture_text

BASE = "https://aphc.gov.in"


def _client():
    return httpx.Client(base_url=BASE, follow_redirects=False, timeout=5)


@respx.mock
def test_court_wise_sequence_and_cookie_continuity():
    seen = []

    def record(request: httpx.Request):
        seen.append((request.method, request.url.path, dict(request.url.params),
                     {k: v[0] for k, v in parse_qs(request.content.decode()).items()},
                     request.headers.get("cookie")))
        if request.url.path.endswith("search.jsp"):
            return httpx.Response(200, text="<html/>", headers={"set-cookie": "HCDBS_ID=xyz; Path=/Hcdbs"})
        if request.url.path.endswith("courtlist.jsp"):
            return httpx.Response(200, text=fixture_text("hcdbs/courtlist_b64.txt"))
        if request.url.path.endswith("searchtype.action"):
            return httpx.Response(200, text=fixture_text("hcdbs/court_list.html"))
        return httpx.Response(200, text="<html/>")

    respx.route(host="aphc.gov.in").mock(side_effect=record)
    with HcdbsSession("D", date(2026, 11, 18), client=_client()) as s:
        courts = s.courts()
        parsed = s.court_list("3")
    assert [c.court_no for c in courts] == ["1", "3"] and len(parsed.items) == 4
    paths = [(m, p) for m, p, *_ in seen]
    assert paths == [("GET", "/Hcdbs/search.jsp"), ("POST", "/Hcdbs/searchdates.action"),
                     ("POST", "/Hcdbs/searchtypeinput.action"), ("GET", "/Hcdbs/courtlist.jsp"),
                     ("POST", "/Hcdbs/searchtype.action")]
    assert seen[1][3] == {"causelisttype": "D"}
    assert seen[2][3] == {"listdate": "18-11-2026", "caset": "courtsearch", "causelisttype": "D"}
    assert seen[3][2] == {"listtype1": "D", "listdate1": "18-11-2026"}
    assert seen[4][3] == {"court": "3", "caset": "courtsearch", "listdate": "18-11-2026", "causelisttype": "D"}
    assert all("HCDBS_ID=xyz" in (c or "") for *_, c in seen[1:])


def test_rejects_bad_inputs():
    with pytest.raises(ValueError):
        HcdbsSession("X", date(2026, 1, 1), client=_client())
    with pytest.raises(ValueError):
        HcdbsSession("D", date(2026, 1, 1), client=_client()).court_list("3 OR 1=1")


@respx.mock
def test_block_page_is_classified():
    respx.get(f"{BASE}/Hcdbs/getdates.jsp").mock(return_value=httpx.Response(
        404, text="<div>The specified URL cannot be found.</div>"))
    with pytest.raises(UpstreamBlocked):
        AphcClient(_client()).list_dates("W")


@respx.mock
def test_pdf_download_allow_list_and_type_check():
    c = AphcClient(_client())
    with pytest.raises(ValueError):
        c.download_pdf("https://evil.example/x.pdf")
    with pytest.raises(ValueError):
        c.download_pdf("/Hcdbs/upload/../../etc/passwd.pdf")
    respx.get(f"{BASE}/Hcdbs/upload/weeklylist.pdf").mock(
        return_value=httpx.Response(200, content=b"<html>not pdf</html>", headers={"content-type": "text/html"}))
    with pytest.raises(UpstreamProtocolError):
        c.download_pdf("/Hcdbs/upload/weeklylist.pdf")
    respx.get(f"{BASE}/Hcdbs/upload/court3_20261118.pdf").mock(
        return_value=httpx.Response(200, content=b"%PDF-1.4 x", headers={"content-type": "application/pdf",
                                                                        "last-modified": "Fri"}))
    assert c.download_pdf("/Hcdbs/upload/court3_20261118.pdf") == (b"%PDF-1.4 x", "Fri")
