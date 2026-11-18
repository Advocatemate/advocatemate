"""Controlled live smoke test of the APHC integrations (~13 throttled requests).

Run manually only, never in CI:  python -m scripts.live_smoke
Prints structure/counts only - no party names, cookies or raw responses.
"""

from datetime import date

from app.integrations.aphc.client import AphcClient
from app.integrations.lexika.client import LexikaClient
from app.utils.case_identity import CaseIdentity


def main() -> None:
    aphc = AphcClient()
    dates = aphc.list_dates("D")
    print("Hcdbs daily dates:", [d.isoformat() for d in dates[:3]])
    d = dates[0]
    with aphc.session("D", d) as s:
        courts = s.courts()
        print("courts offered:", len(courts))
        first = courts[0].court_no
        parsed = s.court_list(first)
        print(f"court {first}: items={len(parsed.items)} headings={len(parsed.headings)} "
              f"first_item={parsed.items[0].item_no if parsed.items else None}")
    board = aphc.publication_board()
    print("online board:", board.list_date, "rows:", len(board.rows))
    disp = aphc.display_board()
    print("display board rows:", len(disp), "in progress:", sum(r.state == "in_progress" for r in disp))
    aphc.close()

    if not parsed.items:
        raise SystemExit("court list had no items; nothing to check with Lexika")
    case = parsed.items[0].case_display
    r = LexikaClient().case_status(CaseIdentity.parse(case))
    print("lexika case_status:", r.identity.slash, "calls:", r.calls_made, "sections:", r.section_status,
          "parties:", len(r.petitioners), "/", len(r.respondents), "vakalath:", len(r.vakalath),
          "primary labels:", sorted(r.primary.get("PRIMARY DETAILS", {}))[:5])
    _ = date


if __name__ == "__main__":
    main()
