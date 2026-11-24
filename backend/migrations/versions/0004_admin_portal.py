"""admin portal: admin accounts and sessions, daily activity, sync events, audit admin actor

Revision ID: 0004
Revises: 0003
Create Date: 2026-11-24 15:10:00
"""
from alembic import op
import sqlalchemy as sa

from app.db import audit_guard

revision = '0004'
down_revision = '0003'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "admin_accounts",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("email", sa.String(length=320), nullable=False),
        sa.Column("google_sub", sa.String(length=255), nullable=True),
        sa.Column("display_name", sa.String(length=255), nullable=True),
        sa.Column("role", sa.String(length=16), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("added_by_admin_id", sa.Uuid(), nullable=True),
        sa.Column("added_via", sa.String(length=16), nullable=False),
        sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["added_by_admin_id"], ["admin_accounts.id"],
                                name=op.f("fk_admin_accounts_added_by_admin_id_admin_accounts"), ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_accounts")),
        sa.UniqueConstraint("email", name=op.f("uq_admin_accounts_email")),
        sa.UniqueConstraint("google_sub", name=op.f("uq_admin_accounts_google_sub")),
    )
    op.create_table(
        "admin_sessions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("admin_account_id", sa.Uuid(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("csrf_token", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("reauth_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ip_hash", sa.String(length=64), nullable=True),
        sa.Column("user_agent", sa.String(length=255), nullable=True),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("revoke_reason", sa.String(length=32), nullable=True),
        sa.ForeignKeyConstraint(["admin_account_id"], ["admin_accounts.id"],
                                name=op.f("fk_admin_sessions_admin_account_id_admin_accounts"), ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_sessions")),
        sa.UniqueConstraint("token_hash", name=op.f("uq_admin_sessions_token_hash")),
    )
    op.create_index(op.f("ix_admin_sessions_admin_account_id"), "admin_sessions", ["admin_account_id"], unique=False)
    op.create_table(
        "user_daily_activity",
        sa.Column("activity_date", sa.Date(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_user_daily_activity_user_id_users"),
                                ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("activity_date", "user_id", name=op.f("pk_user_daily_activity")),
    )
    op.create_table(
        "sync_events",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("list_type", sa.String(length=1), nullable=False),
        sa.Column("list_date", sa.Date(), nullable=False),
        sa.Column("court_no", sa.String(length=16), nullable=False),
        sa.Column("trigger", sa.String(length=16), nullable=False),
        sa.Column("result", sa.String(length=16), nullable=False),
        sa.Column("error_code", sa.String(length=64), nullable=True),
        sa.Column("item_count", sa.Integer(), nullable=True),
        sa.Column("duration_ms", sa.Integer(), nullable=True),
        sa.Column("admin_account_id", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["admin_account_id"], ["admin_accounts.id"],
                                name=op.f("fk_sync_events_admin_account_id_admin_accounts"), ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_sync_events")),
    )
    op.create_index("ix_sync_events_list_date_court_no", "sync_events", ["list_date", "court_no"], unique=False)
    op.create_index(op.f("ix_sync_events_created_at"), "sync_events", ["created_at"], unique=False)

    with op.batch_alter_table("audit_records") as batch:
        batch.add_column(sa.Column("actor_admin_id", sa.Uuid(), nullable=True))
        batch.create_foreign_key(op.f("fk_audit_records_actor_admin_id_admin_accounts"), "admin_accounts",
                                 ["actor_admin_id"], ["id"], ondelete="SET NULL")
        batch.create_index(op.f("ix_audit_records_actor_admin_id"), ["actor_admin_id"], unique=False)

    if op.get_bind().dialect.name == "postgresql":
        op.execute(audit_guard.CREATE_SQL)


def downgrade() -> None:
    if op.get_bind().dialect.name == "postgresql":
        op.execute(audit_guard.DROP_SQL)
    with op.batch_alter_table("audit_records") as batch:
        batch.drop_index(op.f("ix_audit_records_actor_admin_id"))
        batch.drop_constraint(op.f("fk_audit_records_actor_admin_id_admin_accounts"), type_="foreignkey")
        batch.drop_column("actor_admin_id")
    op.drop_index(op.f("ix_sync_events_created_at"), table_name="sync_events")
    op.drop_index("ix_sync_events_list_date_court_no", table_name="sync_events")
    op.drop_table("sync_events")
    op.drop_table("user_daily_activity")
    op.drop_index(op.f("ix_admin_sessions_admin_account_id"), table_name="admin_sessions")
    op.drop_table("admin_sessions")
    op.drop_table("admin_accounts")
