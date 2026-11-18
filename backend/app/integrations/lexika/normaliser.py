"""Map Lexika primary-details labels (as returned by the source) to cache columns.

Only labels actually observed in a Lexika response are mapped. Anything else is
kept verbatim in ``extra_fields`` so no source data is lost or invented.
"""

from __future__ import annotations

from app.integrations.lexika.parsers import parse_dmy

_TEXT = {
    ("PRIMARY DETAILS", "Main Number"): "main_number",
    ("PRIMARY DETAILS", "SR Number"): "sr_number",
    ("PRIMARY DETAILS", "Petitioner"): "petitioner",
    ("PRIMARY DETAILS", "Respondent"): "respondent",
    ("PRIMARY DETAILS", "Petitioner Advocate"): "petitioner_advocate",
    ("PRIMARY DETAILS", "Respondent Advocate"): "respondent_advocate",
    ("PRIMARY DETAILS", "Case Category"): "case_category",
    ("PRIMARY DETAILS", "District"): "district",
    ("PRIMARY DETAILS", "Status"): "status",
    ("PRIMARY DETAILS", "Disposal Type"): "disposal_type",
    ("PRIMARY DETAILS", "Purpose"): "purpose",
    ("PRIMARY DETAILS", "Hon'ble Judges"): "judges",
    ("CATEGORY", "Category"): "category",
    ("CATEGORY", "Sub Category"): "sub_category",
}
_DATES = {
    ("PRIMARY DETAILS", "Filing Date"): "filing_date",
    ("PRIMARY DETAILS", "Registration Date"): "registration_date",
    ("PRIMARY DETAILS", "Listing Date"): "listing_date",
    ("PRIMARY DETAILS", "Disposal Date"): "disposal_date",
}


def _blank(v: str | None) -> bool:
    return v is None or v.strip() in ("", "-", "NA", "N/A")


def normalise_primary(sections: dict[str, dict[str, str]]) -> tuple[dict, dict]:
    columns: dict = {}
    extra: dict = {}
    for section, pairs in sections.items():
        for label, value in pairs.items():
            key = (section, label)
            if key in _TEXT:
                columns[_TEXT[key]] = None if _blank(value) else value.strip()
            elif key in _DATES:
                columns[_DATES[key]] = None if _blank(value) else parse_dmy(value)
            elif not _blank(value):
                extra[f"{section} / {label}"] = value
    return columns, extra
