"""APHC Hcdbs (official cause-list site) client.

Request sequence verified on 2026-11-18 (docs/APHC_INTEGRATION.md):

1. ``GET  /Hcdbs/search.jsp``                       - establishes HCDBS_ID cookie
2. ``POST /Hcdbs/searchdates.action``  causelisttype=D|W|S
3. ``GET  /Hcdbs/getdates.jsp?listtype=X``          - available dates
4. ``POST /Hcdbs/searchtypeinput.action`` listdate, caset=courtsearch, causelisttype
5. ``GET  /Hcdbs/courtlist.jsp?listtype1=X&listdate1=dd-mm-yyyy`` - base64 JSON courts
6. ``POST /Hcdbs/searchtype.action`` court, caset=courtsearch, listdate, causelisttype

Advocate-code-wise search on this site requires a CAPTCHA, so it is NOT used;
the Lexika chatbot provides the advocate view instead. The court-wise flow has
no CAPTCHA.
"""

from __future__ import annotations

from datetime import date

import httpx

from app.integrations.aphc import parsers
from app.integrations.http import new_client, request

CLIENT_VERSION = "1.0"
LIST_TYPES = {"D": "daily", "W": "weekly", "S": "supplementary"}
_BASE = "/Hcdbs"


class HcdbsSession:
    """One cookie-bearing browsing session for a list type + date."""

    def __init__(self, list_type: str, list_date: date, client: httpx.Client | None = None):
        if list_type not in LIST_TYPES:
            raise ValueError("list_type must be D, W or S")
        self.list_type = list_type
        self.list_date = list_date
        self._client = client or new_client()
        self._owns_client = client is None
        self._ready = False

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    def close(self):
        if self._owns_client:
            self._client.close()

    def _open(self) -> None:
        if self._ready:
            return
        c = self._client
        request(c, "GET", f"{_BASE}/search.jsp")
        request(
            c,
            "POST",
            f"{_BASE}/searchdates.action",
            data={"causelisttype": self.list_type},
            headers={"Referer": f"{c.base_url}{_BASE}/search.jsp"},
        )
        request(
            c,
            "POST",
            f"{_BASE}/searchtypeinput.action",
            data={
                "listdate": parsers.format_ddmmyyyy(self.list_date),
                "caset": "courtsearch",
                "causelisttype": self.list_type,
            },
            headers={"Referer": f"{c.base_url}{_BASE}/searchdates.action"},
        )
        self._ready = True

    def courts(self) -> list[parsers.CourtOption]:
        self._open()
        resp = request(
            self._client,
            "GET",
            f"{_BASE}/courtlist.jsp",
            params={"listtype1": self.list_type, "listdate1": parsers.format_ddmmyyyy(self.list_date)},
            headers={"X-Requested-With": "XMLHttpRequest"},
        )
        return parsers.parse_court_list(resp.text)

    def court_list(self, court_no: str) -> parsers.ParsedCauseList:
        if not court_no.isdigit():
            raise ValueError("court_no must be numeric")
        self._open()
        resp = request(
            self._client,
            "POST",
            f"{_BASE}/searchtype.action",
            data={
                "court": court_no,
                "caset": "courtsearch",
                "listdate": parsers.format_ddmmyyyy(self.list_date),
                "causelisttype": self.list_type,
            },
            headers={"Referer": f"{self._client.base_url}{_BASE}/searchtypeinput.action"},
        )
        return parsers.parse_court_cause_list(resp.content)


class AphcClient:
    """Stateless reads (no session needed) + factory for court-wise sessions."""

    def __init__(self, client: httpx.Client | None = None):
        self._client = client

    def _c(self) -> httpx.Client:
        if self._client is None:
            self._client = new_client()
        return self._client

    def close(self):
        if self._client is not None:
            self._client.close()

    def list_dates(self, list_type: str) -> list[date]:
        if list_type not in LIST_TYPES:
            raise ValueError("list_type must be D, W or S")
        resp = request(self._c(), "GET", f"{_BASE}/getdates.jsp", params={"listtype": list_type})
        return parsers.parse_list_dates(resp.text)

    def publication_board(self) -> parsers.PublicationBoard:
        resp = request(self._c(), "GET", f"{_BASE}/online_board.jsp")
        return parsers.parse_online_board(resp.content)

    def display_board(self) -> list[parsers.DisplayBoardRow]:
        resp = request(self._c(), "GET", f"{_BASE}/displaytext.jsp")
        return parsers.parse_display_text(resp.text)

    def session(self, list_type: str, list_date: date) -> HcdbsSession:
        return HcdbsSession(list_type, list_date)

    def download_pdf(self, path: str, max_bytes: int = 40 * 1024 * 1024) -> tuple[bytes, str | None]:
        """Download an official PDF from an allow-listed APHC path."""
        if not path.startswith("/Hcdbs/upload/") or not path.lower().endswith(".pdf") or ".." in path:
            raise ValueError("path is not an allow-listed APHC PDF location")
        resp = request(self._c(), "GET", path)
        ctype = resp.headers.get("content-type", "")
        if "pdf" not in ctype.lower() or not resp.content.startswith(b"%PDF"):
            from app.integrations.http import UpstreamProtocolError

            raise UpstreamProtocolError("source did not return a PDF")
        if len(resp.content) > max_bytes:
            from app.integrations.http import UpstreamProtocolError

            raise UpstreamProtocolError("PDF exceeds size limit")
        return resp.content, resp.headers.get("last-modified")


WEEKLY_PDF_PATH = "/Hcdbs/upload/weeklylist.pdf"
