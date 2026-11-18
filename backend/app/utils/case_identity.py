"""Central case-identity normalisation (handover section 4).

Two representations are in use:

* slash form   ``WP/32115/2023``  - APHC case-details / validation, cause lists
* compact form ``WP321152023``    - Lexika identity and cache keys

Rules implemented here are only those confirmed by source material:

* Case-type pattern ``[A-Za-z()-]{1,20}`` is the pattern used by the official
  APHC cause-list page (``getmaincasedet`` validation regex) - e.g. ``WP(PIL)``.
* Case number is 1..8 digits, year is exactly 4 digits (same official regex).
* Lexika primary/selection responses render identity as ``WP 11111/2026``
  ("<type> <number>/<year>").
* Chatbot advocate cause lists render application rows as
  ``IA/1/2026-Condone Delay Petition,CMA/506/2012`` (application, then main case).

Leading zeros are NOT stripped or added: no source confirms equivalence, so a
number with a leading zero is rejected as ambiguous rather than silently merged.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

_TYPE = r"[A-Za-z()\-]{1,20}"
_SLASH_RE = re.compile(rf"^\s*({_TYPE})\s*/\s*(\d{{1,8}})\s*/\s*(\d{{4}})\s*$")
_SPACED_RE = re.compile(rf"^\s*({_TYPE})\s+(\d{{1,8}})\s*/\s*(\d{{4}})\s*$")
_COMPACT_RE = re.compile(rf"^\s*({_TYPE})(\d{{5,12}})\s*$")
_APPLICATION_ROW_RE = re.compile(
    rf"^\s*({_TYPE}/\d{{1,8}}/\d{{4}})\s*-\s*(.*?)\s*,\s*({_TYPE}/\d{{1,8}}/\d{{4}})\s*$"
)


class InvalidCaseIdentity(ValueError):
    pass


@dataclass(frozen=True, slots=True)
class CaseIdentity:
    case_type: str
    number: str
    year: int

    def __post_init__(self):
        if not re.fullmatch(_TYPE, self.case_type):
            raise InvalidCaseIdentity(f"invalid case type: {self.case_type!r}")
        if not re.fullmatch(r"\d{1,8}", self.number):
            raise InvalidCaseIdentity(f"invalid case number: {self.number!r}")
        if self.number.startswith("0"):
            raise InvalidCaseIdentity("case number with leading zero is ambiguous")
        if not 1900 <= self.year <= 2100:
            raise InvalidCaseIdentity(f"invalid case year: {self.year}")

    # -- constructors ---------------------------------------------------
    @classmethod
    def build(cls, case_type: str, number: str | int, year: str | int) -> CaseIdentity:
        return cls(case_type.strip().upper(), str(number).strip(), int(str(year).strip()))

    @classmethod
    def parse_slash(cls, value: str) -> CaseIdentity:
        m = _SLASH_RE.match(value or "")
        if not m:
            raise InvalidCaseIdentity(f"not a slash-form case identity: {value!r}")
        return cls.build(m.group(1), m.group(2), m.group(3))

    @classmethod
    def parse_spaced(cls, value: str) -> CaseIdentity:
        """Lexika display form: ``WP 11111/2026``."""
        m = _SPACED_RE.match(value or "")
        if not m:
            raise InvalidCaseIdentity(f"not a spaced case identity: {value!r}")
        return cls.build(m.group(1), m.group(2), m.group(3))

    @classmethod
    def parse_compact(cls, value: str) -> CaseIdentity:
        """``WP321152023`` -> WP / 32115 / 2023 (last four digits are the year)."""
        m = _COMPACT_RE.match(value or "")
        if not m:
            raise InvalidCaseIdentity(f"not a compact case identity: {value!r}")
        digits = m.group(2)
        return cls.build(m.group(1), digits[:-4], digits[-4:])

    @classmethod
    def parse(cls, value: str) -> CaseIdentity:
        """Accept slash, spaced or compact input (user search box, deep links)."""
        for parser in (cls.parse_slash, cls.parse_spaced, cls.parse_compact):
            try:
                return parser(value)
            except InvalidCaseIdentity:
                continue
        raise InvalidCaseIdentity(f"unrecognised case identity: {value!r}")

    # -- representations -------------------------------------------------
    @property
    def slash(self) -> str:
        return f"{self.case_type}/{self.number}/{self.year}"

    @property
    def compact(self) -> str:
        return f"{self.case_type}{self.number}{self.year}"

    @property
    def canonical(self) -> str:
        return self.slash

    @property
    def display(self) -> str:
        return f"{self.case_type} {self.number}/{self.year}"

    def __str__(self) -> str:
        return self.slash


@dataclass(frozen=True, slots=True)
class ListedMatter:
    """A row from an advocate cause list: either a main case or an application in a case."""

    main_case: CaseIdentity
    application: CaseIdentity | None = None
    application_description: str | None = None


def parse_listed_matter(value: str) -> ListedMatter:
    text = (value or "").strip()
    m = _APPLICATION_ROW_RE.match(text)
    if m:
        return ListedMatter(
            main_case=CaseIdentity.parse_slash(m.group(3)),
            application=CaseIdentity.parse_slash(m.group(1)),
            application_description=m.group(2) or None,
        )
    return ListedMatter(main_case=CaseIdentity.parse_slash(text))


def same_case(a: CaseIdentity, b: CaseIdentity) -> bool:
    """Strict structural equality - never fuzzy display-string matching."""
    return a.case_type == b.case_type and a.number == b.number and a.year == b.year
