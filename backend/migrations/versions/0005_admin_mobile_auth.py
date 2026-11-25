"""admin mobile app auth: session client/device columns, refresh tokens, one-time sign-in challenges

Revision ID: 0005
Revises: 0004
Create Date: 2026-11-24 18:00:00
"""
from alembic import op
import sqlalchemy as sa

revision = '0005'
down_revision = '0004'
branch_labels = None
depends_on = None


def upgrade() -> None:
    with op.batch_alter_table("admin_sessions") as batch:
        # Existing sessions are all browser sessions (/admin portal or the web Admin App).
        batch.add_column(sa.Column("client", sa.String(length=16), server_default="browser", nullable=False))
        batch.add_column(sa.Column("token_expires_at", sa.DateTime(timezone=True), nullable=True))
        batch.add_column(sa.Column("platform", sa.String(length=16), nullable=True))
        batch.add_column(sa.Column("device_name", sa.String(length=120), nullable=True))
        batch.add_column(sa.Column("app_version", sa.String(length=32), nullable=True))
        batch.add_column(sa.Column("installation_id", sa.String(length=64), nullable=True))

    op.create_table(
        "admin_refresh_tokens",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("admin_session_id", sa.Uuid(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["admin_session_id"], ["admin_sessions.id"],
                                name=op.f("fk_admin_refresh_tokens_admin_session_id_admin_sessions"),
                                ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_refresh_tokens")),
        sa.UniqueConstraint("token_hash", name=op.f("uq_admin_refresh_tokens_token_hash")),
    )
    op.create_index(op.f("ix_admin_refresh_tokens_admin_session_id"), "admin_refresh_tokens", ["admin_session_id"],
                    unique=False)

    op.create_table(
        "admin_auth_challenges",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("nonce_hash", sa.String(length=64), nullable=False),
        sa.Column("purpose", sa.String(length=16), nullable=False),
        sa.Column("admin_session_id", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("ip_hash", sa.String(length=64), nullable=True),
        sa.ForeignKeyConstraint(["admin_session_id"], ["admin_sessions.id"],
                                name=op.f("fk_admin_auth_challenges_admin_session_id_admin_sessions"),
                                ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_admin_auth_challenges")),
        sa.UniqueConstraint("nonce_hash", name=op.f("uq_admin_auth_challenges_nonce_hash")),
    )
    op.create_index(op.f("ix_admin_auth_challenges_admin_session_id"), "admin_auth_challenges",
                    ["admin_session_id"], unique=False)
    op.create_index(op.f("ix_admin_auth_challenges_expires_at"), "admin_auth_challenges", ["expires_at"],
                    unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_admin_auth_challenges_expires_at"), table_name="admin_auth_challenges")
    op.drop_index(op.f("ix_admin_auth_challenges_admin_session_id"), table_name="admin_auth_challenges")
    op.drop_table("admin_auth_challenges")
    op.drop_index(op.f("ix_admin_refresh_tokens_admin_session_id"), table_name="admin_refresh_tokens")
    op.drop_table("admin_refresh_tokens")
    with op.batch_alter_table("admin_sessions") as batch:
        batch.drop_column("installation_id")
        batch.drop_column("app_version")
        batch.drop_column("device_name")
        batch.drop_column("platform")
        batch.drop_column("token_expires_at")
        batch.drop_column("client")
