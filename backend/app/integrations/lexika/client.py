"""LexikaClient - the APHC website chatbot at ``POST https://aphc.gov.in/chatbot.php``.

Access mechanism (verified 2026-11-18): direct HTTPS form POSTs from the
AdvocateMate backend to the public chatbot endpoint, the same requests the
chatbot widget on aphc.gov.in (``/chat_assets/chat.js``) makes. State is held
server-side in a PHP session (``PHPSESSID`` cookie), so every multi-step flow
must reuse ONE cookie jar. No credentials are involved.

Six logical operations of ``case_status()`` - all POST to the same URL:

==  ==========================  ===========================================
#   Operation                   Form body
==  ==========================  ===========================================
1   Transition                  case_status_main=Case Status
2   Case type, number, year     main_case_type=<option value e.g. WP-63>,
                                case_no=<n>, case_year=<yyyy>
3   Primary case details        case_status_query=Case Primary Details
4   Vakalath details            case_status_query=Case Vakalath Details
5   Petitioner details          case_status_query=Case Petitioners Details
6   Respondent details          case_status_query=Case Respondents Details
==  ==========================  ===========================================

The type value for op 2 is read from op 1's own ``<select id="case_type">``
response - it is never hard-coded. Calls are capped at six per case and are
never individually retried: a failure aborts the run and the *job* decides
whether to retry later with a fresh session.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date

import httpx

from app.core.config import get_settings
from app.integrations.http import (
    UpstreamIdentityMismatch,
    UpstreamNotFound,
    UpstreamParseError,
    UpstreamProtocolError,
    new_client,
    request,
)
from app.integrations.lexika import parsers
from app.utils.case_identity import CaseIdentity, same_case

CLIENT_VERSION = "1.0"
ENDPOINT = "/chatbot.php"


@dataclass
class CaseStatusResult:
    identity: CaseIdentity
    primary: dict[str, dict[str, str]]
    vakalath: list[parsers.VakalathEntry]
    petitioners: list[parsers.PartyEntry]
    respondents: list[parsers.PartyEntry]
    available_sections: list[str] = field(default_factory=list)
    section_status: dict[str, str] = field(default_factory=dict)
    calls_made: int = 0


class _CallBudget:
    def __init__(self, limit: int):
        self.limit = limit
        self.used = 0

    def take(self):
        if self.used >= self.limit:
            raise UpstreamProtocolError(f"Lexika call cap of {self.limit} reached")
        self.used += 1


class LexikaClient:
    def __init__(self, client_factory=None):
        self._factory = client_factory or new_client

    def _post(self, client: httpx.Client, budget: _CallBudget | None, data: dict) -> str:
        if budget:
            budget.take()
        resp = request(
            client,
            "POST",
            ENDPOINT,
            data=data,
            headers={
                "X-Requested-With": "XMLHttpRequest",
                "Referer": f"{client.base_url}/",
                "Origin": str(client.base_url).rstrip("/"),
            },
        )
        return resp.text

    # ------------------------------------------------------- case status
    def case_status(self, identity: CaseIdentity) -> CaseStatusResult:
        budget = _CallBudget(get_settings().lexika_max_calls_per_case)
        with self._factory() as client:
            # 1. Transition into the case-status flow; returns the case-type <select>.
            op1 = self._post(client, budget, {"case_status_main": "Case Status"})
            type_map = parsers.parse_case_type_options(op1)
            type_value = type_map.get(identity.case_type.upper())
            if not type_value:
                raise UpstreamNotFound(f"case type {identity.case_type} not offered by Lexika")

            # 2. Select the case.
            op2 = self._post(
                client,
                budget,
                {"main_case_type": type_value, "case_no": identity.number, "case_year": str(identity.year)},
            )
            if not op2.strip():
                raise UpstreamNotFound("Lexika returned no case for this identity")
            returned, sections = parsers.parse_case_selection(op2)
            if not same_case(returned, identity):
                raise UpstreamIdentityMismatch(
                    f"requested {identity.slash} but Lexika selected {returned.slash}"
                )

            status: dict[str, str] = {}

            # 3. Primary details (mandatory).
            primary = parsers.parse_primary_details(
                self._post(client, budget, {"case_status_query": "Case Primary Details"})
            )
            main_no = primary.get("PRIMARY DETAILS", {}).get("Main Number")
            if main_no:
                try:
                    if not same_case(CaseIdentity.parse_spaced(main_no), identity):
                        raise UpstreamIdentityMismatch(f"primary details belong to {main_no}")
                except ValueError as e:
                    raise UpstreamParseError("unreadable Main Number in primary details") from e
            status["primary"] = "present"

            # 4-6. Optional sections: a parse problem in one does not corrupt the others.
            def optional(label: str, key: str, fn):
                if label not in sections:
                    status[key] = "not_offered"
                    return []
                body = self._post(client, budget, {"case_status_query": label})
                try:
                    data = fn(body)
                except UpstreamParseError:
                    status[key] = "parse_failed"
                    return []
                status[key] = "present" if data else "empty"
                return data

            vakalath = optional("Case Vakalath Details", "vakalath", parsers.parse_vakalath)
            petitioners = optional(
                "Case Petitioners Details", "petitioners", lambda b: parsers.parse_parties(b, "PETITIONER")
            )
            respondents = optional(
                "Case Respondents Details", "respondents", lambda b: parsers.parse_parties(b, "RESPONDENT")
            )

            return CaseStatusResult(
                identity=identity,
                primary=primary,
                vakalath=vakalath,
                petitioners=petitioners,
                respondents=respondents,
                available_sections=sections,
                section_status=status,
                calls_made=budget.used,
            )

    # ------------------------------------------------------- advocate view
    def advocate_lookup(self, advocate_code: str) -> parsers.AdvocateLookup:
        _validate_code(advocate_code)
        with self._factory() as client:
            self._post(client, None, {"query": "Advocate Code Wise Search"})
            body = self._post(client, None, {"chat_input": advocate_code})
            return parsers.parse_advocate_lookup(body, advocate_code)

    def advocate_cause_list(
        self, advocate_code: str, list_date: date
    ) -> tuple[parsers.AdvocateLookup, list[parsers.AdvocateListing]]:
        """Returns the lookup plus the rows for ``list_date`` (empty if the date is not offered)."""
        _validate_code(advocate_code)
        with self._factory() as client:
            self._post(client, None, {"query": "Advocate Code Wise Search"})
            lookup = parsers.parse_advocate_lookup(
                self._post(client, None, {"chat_input": advocate_code}), advocate_code
            )
            if list_date not in lookup.available_dates:
                return lookup, []
            body = self._post(client, None, {"query": list_date.strftime("%d-%m-%Y")})
            return lookup, parsers.parse_advocate_cause_list(body)


def _validate_code(code: str) -> None:
    if not code.isdigit() or not 1 <= len(code) <= 8:
        raise ValueError("advocate code must be 1-8 digits")
