"""google sign-in and advocate registry

Revision ID: 0002
Revises: 0001
Create Date: 2026-11-19 16:02:47.225570
"""
from alembic import op
import sqlalchemy as sa


revision = '0002'
down_revision = '0001'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "advocate_registry",
        sa.Column("advocate_code", sa.String(length=16), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("email_normalized", sa.String(length=320), nullable=True),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("source", sa.String(length=64), nullable=False),
        sa.Column("source_reference", sa.String(length=128), nullable=True),
        sa.Column("imported_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("advocate_code", name=op.f("pk_advocate_registry")),
    )
    op.create_index(op.f("ix_advocate_registry_email_normalized"), "advocate_registry", ["email_normalized"],
                    unique=False)

    # Batch mode keeps this runnable on SQLite (local unit tests) as well as PostgreSQL.
    with op.batch_alter_table("advocate_profiles") as batch:
        batch.add_column(sa.Column("google_sub", sa.String(length=255), nullable=True))
        batch.add_column(sa.Column("google_email", sa.String(length=320), nullable=True))
        batch.add_column(sa.Column("linked_at", sa.DateTime(timezone=True), nullable=True))
        batch.add_column(sa.Column("verification_method", sa.String(length=32), nullable=True))
        batch.alter_column("identity_verification", existing_type=sa.VARCHAR(length=16),
                           type_=sa.String(length=24), existing_nullable=False)
        batch.create_unique_constraint(op.f("uq_advocate_profiles_google_sub"), ["google_sub"])

    # Every existing profile came from the retired mobile-OTP login and was never matched against
    # an authoritative registry: it cannot sign in until a Google account passes the registry check.
    # Rows are kept (favourites, history) - nothing is deleted.
    op.execute("UPDATE advocate_profiles SET identity_verification = 'legacy_unverified'")


def downgrade() -> None:
    op.execute("UPDATE advocate_profiles SET identity_verification = 'self_declared'")
    with op.batch_alter_table("advocate_profiles") as batch:
        batch.drop_constraint(op.f("uq_advocate_profiles_google_sub"), type_="unique")
        batch.alter_column("identity_verification", existing_type=sa.String(length=24),
                           type_=sa.VARCHAR(length=16), existing_nullable=False)
        batch.drop_column("verification_method")
        batch.drop_column("linked_at")
        batch.drop_column("google_email")
        batch.drop_column("google_sub")
    op.drop_index(op.f("ix_advocate_registry_email_normalized"), table_name="advocate_registry")
    op.drop_table("advocate_registry")
