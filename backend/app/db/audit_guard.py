"""PostgreSQL rule that keeps audit records append-only (installed by migration 0004).

Rows cannot be deleted or changed. The only permitted change is the database itself setting an actor
reference to NULL when that user or admin account is deleted (the foreign keys use ON DELETE SET NULL).
"""

CREATE_SQL = """
CREATE OR REPLACE FUNCTION audit_records_append_only() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'audit records are append-only';
    END IF;
    IF NEW.id IS DISTINCT FROM OLD.id
       OR NEW.action IS DISTINCT FROM OLD.action
       OR NEW.target_type IS DISTINCT FROM OLD.target_type
       OR NEW.target_id IS DISTINCT FROM OLD.target_id
       OR NEW.ip_hash IS DISTINCT FROM OLD.ip_hash
       OR NEW.details::text IS DISTINCT FROM OLD.details::text
       OR NEW.created_at IS DISTINCT FROM OLD.created_at
       OR (NEW.actor_user_id IS DISTINCT FROM OLD.actor_user_id AND NEW.actor_user_id IS NOT NULL)
       OR (NEW.actor_admin_id IS DISTINCT FROM OLD.actor_admin_id AND NEW.actor_admin_id IS NOT NULL) THEN
        RAISE EXCEPTION 'audit records are append-only';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_audit_records_append_only
    BEFORE UPDATE OR DELETE ON audit_records
    FOR EACH ROW EXECUTE FUNCTION audit_records_append_only();
"""

DROP_SQL = """
DROP TRIGGER IF EXISTS trg_audit_records_append_only ON audit_records;
DROP FUNCTION IF EXISTS audit_records_append_only();
"""
