"""passed-over items and parsed cause-list PDFs

Revision ID: 0003
Revises: 0002
Create Date: 2026-11-20 16:30:00
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = '0003'
down_revision = '0002'
branch_labels = None
depends_on = None

_json = sa.JSON().with_variant(postgresql.JSONB(), "postgresql")


def upgrade() -> None:
    op.create_table(
        "cause_list_pdf_parses",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("list_type", sa.String(length=1), nullable=False),
        sa.Column("list_date", sa.Date(), nullable=False),
        sa.Column("court_no", sa.String(length=16), nullable=False),
        sa.Column("source_url", sa.String(length=512), nullable=True),
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.Column("pdf_document_id", sa.Uuid(), nullable=True),
        sa.Column("parser_version", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("error_code", sa.String(length=64), nullable=True),
        sa.Column("page_count", sa.Integer(), nullable=False),
        sa.Column("item_count", sa.Integer(), nullable=False),
        sa.Column("bench", sa.String(length=255), nullable=True),
        sa.Column("headings", _json, nullable=False),
        sa.Column("items", _json, nullable=False),
        sa.Column("parsed_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["pdf_document_id"], ["pdf_documents.id"],
                                name=op.f("fk_cause_list_pdf_parses_pdf_document_id_pdf_documents"),
                                ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_cause_list_pdf_parses")),
        sa.UniqueConstraint("list_type", "list_date", "court_no",
                            name=op.f("uq_cause_list_pdf_parses_list_type_list_date_court_no")),
    )
    op.create_index(op.f("ix_cause_list_pdf_parses_list_date"), "cause_list_pdf_parses", ["list_date"], unique=False)

    op.create_table(
        "passed_over_items",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("list_date", sa.Date(), nullable=False),
        sa.Column("court_no", sa.String(length=16), nullable=False),
        sa.Column("list_prefix", sa.String(length=4), nullable=False),
        sa.Column("item_no", sa.String(length=16), nullable=False),
        sa.Column("pending", sa.Boolean(), nullable=False),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_pending_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("removed_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_passed_over_items")),
        sa.UniqueConstraint("list_date", "court_no", "list_prefix", "item_no",
                            name=op.f("uq_passed_over_items_list_date_court_no_list_prefix_item_no")),
    )
    op.create_index(op.f("ix_passed_over_items_list_date"), "passed_over_items", ["list_date"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_passed_over_items_list_date"), table_name="passed_over_items")
    op.drop_table("passed_over_items")
    op.drop_index(op.f("ix_cause_list_pdf_parses_list_date"), table_name="cause_list_pdf_parses")
    op.drop_table("cause_list_pdf_parses")
