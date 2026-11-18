"""Full-stack local check through the HTTP API with LIVE APHC data (~20 throttled upstream calls).

Prereq: API running locally with UPSTREAM_ENABLED=true and OTP_PROVIDER=dev_echo.
Usage:  python -m scripts.e2e_local http://127.0.0.1:8077 <advocate_code> <10-digit-test-mobile>
Prints shapes/counts only.
"""

import sys
import time
from datetime import date

import httpx

from app.db.session import db_session  # noqa: F401  (uses DATABASE_URL from env)
from app.services import enrichment, live_board

base, code, mobile = sys.argv[1], sys.argv[2], sys.argv[3]
c = httpx.Client(base_url=f"{base}/api/v1", timeout=120)


def ok(r: httpx.Response) -> dict:
    if r.status_code >= 400:
        raise SystemExit(f"{r.request.method} {r.request.url.path} -> {r.status_code} {r.text[:300]}")
    return r.json() if r.content else {}


reg = ok(c.post("/auth/register", json={"advocate_code": code}))
print("register:", reg["advocate_name"] != "", "already_registered:", reg["already_registered"])
sent = ok(c.post("/auth/send-otp", json={"advocate_code": code, "mobile": mobile, "identity_confirmed": True}))
tok = ok(c.post("/auth/verify-otp", json={"advocate_code": code, "mobile": mobile, "otp": sent["dev_otp"]}))
c.headers["Authorization"] = f"Bearer {tok['access_token']}"
me = ok(c.get("/auth/me"))
print("me:", me["advocate_code"], me["identity_verification"])

dates = ok(c.get("/cause-list/dates", params={"list_type": "D"}))
d = dates["dates"][0]
courts = ok(c.get("/cause-list/courts", params={"list_type": "D", "date": d}))
print("daily", d, "courts:", len(courts["courts"]))
court_no = courts["courts"][0]["court_no"]
listing = ok(c.get(f"/cause-list/court/{court_no}", params={"list_type": "D", "date": d}))
print(f"court {court_no}: total_cases={listing['total_cases']} first_item={listing['items'][0]['item_no']}")

mine = ok(c.get(f"/cause-list/advocate/{code}", params={"date": d}))
print("advocate list:", mine["total_cases"], "cases in", len(mine["courts"]), "courts; offered:", mine["date_offered_by_source"])

case_no = listing["items"][0]["case_number"]
details = ok(c.get("/case-details", params={"case_number": case_no}))
case_id = details["identity"]["case_id"]
print("case-details immediate state:", details["enrichment"]["state"])

owner = "e2e-local"
ids = enrichment.claim_due_jobs(owner)
print("worker claimed:", len(ids), "->", [enrichment.run_job(i, owner) for i in ids])
status = ok(c.get(f"/cases/{case_id}/enrichment-status"))
details = ok(c.get(f"/cases/{case_id}"))
print("after worker:", status["state"], status["freshness"],
      "| info keys:", sorted(details["information"])[:6],
      "| petitioners:", len(details["parties"].get("petitioners", [])),
      "respondents:", len(details["parties"].get("respondents", [])),
      "vakalath:", len(details["advocates"].get("vakalath", [])))

pdf = c.get(f"/cases/{case_id}/pdf")
print("summary pdf:", pdf.status_code, pdf.headers.get("x-document-official"), len(pdf.content), "bytes")

with db_session() as db:
    print("display rows polled:", live_board.poll_display_board(db))
live = ok(c.get("/live-courts"))
print("live board current:", live["is_current"], "courts:", len(live["courts"]))
pub = ok(c.get("/cause-list/status"))
print("publication:", pub["list_date"], pub["summary"])
weekly = c.get("/cause-list/weekly.pdf")
print("weekly pdf:", weekly.status_code, weekly.headers.get("x-document-official"), weekly.content[:5])
ok(c.post("/auth/logout"))
print("logout ok; me after logout ->", c.get("/auth/me").status_code)
_ = (time, date)
