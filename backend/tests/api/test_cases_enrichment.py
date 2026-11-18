from sqlalchemy import func, select

from app.integrations.http import UpstreamTimeout
from app.models import LexikaCaseParty, LexikaCaseStatusEnrichmentJob, LexikaCaseVakalathMapping, Notification
from app.services import circuit, enrichment
from app.utils.case_identity import CaseIdentity


def _run_all(owner="test-worker"):
    results = []
    for job_id in enrichment.claim_due_jobs(owner):
        results.append(enrichment.run_job(job_id, owner))
    return results


def test_case_details_returns_immediately_and_queues_job(client, user_headers, fake_lexika):
    r = client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["identity"]["display"] == "WP/11111/2026"
    # Not blocked on upstream: no case-status call happened during the request.
    assert body["enrichment"]["state"] == "pending"
    assert not [c for c in fake_lexika.calls if c[0] == "case_status"]
    # second request (other accepted format) does not create a duplicate job
    again = client.get("/api/v1/case-details?case_number=WP 11111/2026", headers=user_headers).json()
    assert again["enrichment"]["job"]["id"] == body["enrichment"]["job"]["id"]
    assert body["unavailable_sections"]


def test_enrichment_completes_and_is_served(client, user_headers, fake_lexika, engine):
    case_id = client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers).json()["identity"]["case_id"]
    assert _run_all() == ["succeeded"]
    status = client.get(f"/api/v1/cases/{case_id}/enrichment-status", headers=user_headers).json()
    assert status["state"] == "completed" and status["freshness"] == "fresh"
    d = client.get(f"/api/v1/cases/{case_id}", headers=user_headers).json()
    assert d["information"]["status"] == "PENDING" and d["information"]["filing_date"] == "2026-10-26"
    assert "disposal_date" not in d["information"]  # absent in source -> omitted, not invented
    assert [p["name"] for p in d["parties"]["respondents"]] == ["THE STATE OF ANDHRA PRADESH", "The District Collector.,"]
    assert d["advocates"]["vakalath"][0]["advocate_code"] == "12345"
    assert d["provenance"]["source"] == "aphc_lexika_chatbot"
    # requester was notified (history recorded even though push is not configured)
    with engine.connect() as c:
        n = c.execute(select(Notification)).first()
        assert n.category == "enrichment" and n.delivery_status == "skipped"


def test_repeated_enrichment_does_not_duplicate_rows(client, user_headers, engine):
    case_id = client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers).json()["identity"]["case_id"]
    _run_all()
    client.post(f"/api/v1/cases/{case_id}/refresh", headers=user_headers)
    _run_all()
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(LexikaCaseParty)).scalar() == 3
        # fixture repeats one vakalath row; duplicates are collapsed
        assert c.execute(select(func.count()).select_from(LexikaCaseVakalathMapping)).scalar() == 2


def test_identity_mismatch_is_never_stored(client, user_headers, fake_lexika, engine):
    fake_lexika.return_identity = CaseIdentity.parse("WP/99999/2026")
    case_id = client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers).json()["identity"]["case_id"]
    assert _run_all() == ["failed"]
    s = client.get(f"/api/v1/cases/{case_id}/enrichment-status", headers=user_headers).json()
    assert s["state"] == "failed" and s["job"]["error_code"] == "identity_mismatch"
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(LexikaCaseParty)).scalar() == 0


def test_transient_failure_schedules_retry_with_backoff(client, user_headers, fake_lexika, engine):
    fake_lexika.fail_with = UpstreamTimeout("slow")
    client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers)
    assert _run_all() == ["pending"]
    with engine.connect() as c:
        job = c.execute(select(LexikaCaseStatusEnrichmentJob)).first()
        assert job.attempts == 1 and job.last_error_code == "upstream_timeout"
    assert _run_all() == []  # backoff: not due yet


def test_circuit_opens_after_repeated_failures(client, user_headers, fake_lexika, monkeypatch):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "circuit_failure_threshold", 2)
    monkeypatch.setattr(get_settings(), "enrichment_backoff_base_seconds", 0)
    fake_lexika.fail_with = UpstreamTimeout("slow")
    client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers)
    client.get("/api/v1/case-details?case_number=WP/22/2025", headers=user_headers)
    _run_all()
    calls_before = len(fake_lexika.calls)
    _run_all()  # circuit now open: jobs are deferred without calling upstream
    assert len(fake_lexika.calls) == calls_before
    from app.db.session import db_session
    from app.models import LexikaSafetyCircuit

    with db_session() as db:
        assert db.get(LexikaSafetyCircuit, circuit.LEXIKA).state == "open"


def test_lease_prevents_double_execution(client, user_headers):
    client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers)
    ids_a = enrichment.claim_due_jobs("worker-a")
    ids_b = enrichment.claim_due_jobs("worker-b")
    assert len(ids_a) == 1 and ids_b == []
    assert enrichment.run_job(ids_a[0], "worker-b") == "skipped"
    assert enrichment.run_job(ids_a[0], "worker-a") == "succeeded"


def test_invalid_case_number(client, user_headers):
    r = client.get("/api/v1/case-details?case_number=hello", headers=user_headers)
    assert r.status_code == 422 and r.json()["error"]["code"] == "invalid_case_number"


def test_generated_summary_pdf_is_labelled_and_order_pdf_unavailable(client, user_headers):
    case_id = client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers).json()["identity"]["case_id"]
    _run_all()
    r = client.get(f"/api/v1/cases/{case_id}/pdf", headers=user_headers)
    assert r.status_code == 200 and r.content.startswith(b"%PDF")
    assert r.headers["x-document-official"] == "false" and "generated" in r.headers["content-disposition"]
    r = client.get(f"/api/v1/cases/{case_id}/pdf?kind=order", headers=user_headers)
    assert r.status_code == 404 and r.json()["error"]["code"] == "official_order_unavailable"


def test_unknown_case_id(client, user_headers):
    r = client.get("/api/v1/cases/00000000-0000-0000-0000-000000000000", headers=user_headers)
    assert r.status_code == 404
