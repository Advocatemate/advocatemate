from app.integrations.http import UpstreamUnavailable


def test_dates_and_courts(client, user_headers, fake_aphc):
    r = client.get("/api/v1/cause-list/dates?list_type=D", headers=user_headers)
    assert r.status_code == 200 and r.json()["dates"][0] == "2026-11-18"
    r = client.get("/api/v1/cause-list/courts?list_type=D&date=2026-11-18", headers=user_headers)
    assert [c["court_no"] for c in r.json()["courts"]] == ["1", "3"]
    # cached: no second upstream call
    client.get("/api/v1/cause-list/courts?list_type=D&date=2026-11-18", headers=user_headers)
    assert sum(1 for c in fake_aphc.calls if c[0] == "courts") == 1


def test_invalid_list_type(client, user_headers):
    r = client.get("/api/v1/cause-list/dates?list_type=X", headers=user_headers)
    assert r.status_code == 422


def test_court_listing_keeps_source_order_and_counts(client, user_headers, fake_aphc):
    r = client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["total_cases"] == 4 and body["bench"].endswith("SAMPLE JUDGE")
    assert [i["item_no"] for i in body["items"]] == ["1", "2", "59", "59.1"]
    assert body["items"][0]["case_id"] and body["items"][0]["applications"][0]["number"] == "IA 1/2026"
    # count now visible on courts endpoint
    courts = client.get("/api/v1/cause-list/courts?list_type=D&date=2026-11-18", headers=user_headers).json()
    assert {c["court_no"]: c["case_count"] for c in courts["courts"]}["3"] == 4
    # served from DB on repeat
    client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    assert sum(1 for c in fake_aphc.calls if c[0] == "court_list") == 1


def test_weekly_and_supplementary_are_kept_separate(client, user_headers):
    d = client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers).json()
    w = client.get("/api/v1/cause-list/court/3?list_type=W&date=2026-11-18", headers=user_headers).json()
    s = client.get("/api/v1/cause-list/court/3?list_type=S&date=2026-11-18", headers=user_headers).json()
    assert (d["list_type"], w["list_type"], s["list_type"]) == ("D", "W", "S")


def test_upstream_failure_without_cache_is_reported(client, user_headers, fake_aphc):
    fake_aphc.fail_with = UpstreamUnavailable("down")
    r = client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    assert r.status_code == 502 and r.json()["error"]["code"] == "upstream_unavailable"


def test_upstream_failure_with_cache_serves_stale(client, user_headers, fake_aphc, engine):
    client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    from datetime import timedelta

    from sqlalchemy import update

    from app.db.base import utcnow
    from app.models import CauseList

    with engine.begin() as c:
        c.execute(update(CauseList).values(fetched_at=utcnow() - timedelta(hours=3)))
    fake_aphc.fail_with = UpstreamUnavailable("down")
    r = client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    assert r.status_code == 200 and r.json()["stale"] is True and r.json()["total_cases"] == 4


def test_advocate_cause_list_grouped_by_court_and_enriched_from_court_list(client, user_headers):
    # Sync court 3 first so party names can be joined from the official court list.
    client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    r = client.get("/api/v1/cause-list/advocate/12345?date=2026-11-18", headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["advocate_name"] == "ADVOCATE ONE" and body["total_cases"] == 3
    assert [g["court_no"] for g in body["courts"]] == ["1", "3", "18"]
    court3 = body["courts"][1]["cases"][0]
    assert court3["case_number"] == "WP/11111/2026" and court3["petitioner"] == "PETITIONER ALPHA"
    court18 = body["courts"][2]["cases"][0]
    assert court18["case_number"] == "CMA/506/2012" and court18["application"] == "IA/1/2026"
    assert court18["petitioner"] is None  # not fabricated when no source row exists


def test_advocate_date_not_offered_returns_empty(client, user_headers):
    r = client.get("/api/v1/cause-list/advocate/12345?date=2026-01-05", headers=user_headers)
    assert r.status_code == 200 and r.json()["total_cases"] == 0 and r.json()["date_offered_by_source"] is False


def test_overview(client, user_headers):
    r = client.get("/api/v1/cause-list?list_type=D", headers=user_headers)
    assert r.status_code == 200 and r.json()["date_offered_by_source"] and len(r.json()["courts"]) == 2
