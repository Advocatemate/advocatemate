"""Import the authoritative advocate registry from a CSV file.

    python -m scripts.import_registry registry.csv --source "<official source name>" [--dry-run] [--keep-missing]

CSV header: advocate_code,full_name,email,status[,source_reference]
status: active | inactive | suspended | struck_off | deceased | retired

Run with --dry-run first and review the report. Without --keep-missing, codes that are in the
database but not in this file become inactive (they lose access).
"""

from __future__ import annotations

import argparse
import csv
import sys

from app.db.session import db_session
from app.services.registry import RegistryImportError, import_rows

REQUIRED = {"advocate_code", "full_name", "email", "status"}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("csv_path")
    ap.add_argument("--source", required=True, help="name of the official source this file came from")
    ap.add_argument("--dry-run", action="store_true", help="show what would change without saving")
    ap.add_argument("--keep-missing", action="store_true", help="do not deactivate codes missing from this file")
    args = ap.parse_args(argv)

    with open(args.csv_path, newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        missing = REQUIRED - set(reader.fieldnames or [])
        if missing:
            print(f"CSV is missing columns: {sorted(missing)}", file=sys.stderr)
            return 2
        rows = list(reader)

    try:
        with db_session() as db:
            report = import_rows(db, rows, source=args.source, keep_missing=args.keep_missing,
                                 dry_run=args.dry_run)
    except RegistryImportError as e:
        print(str(e), file=sys.stderr)
        return 2

    print(("DRY RUN - nothing saved. " if args.dry_run else "Imported. ") + str(report.summary()))
    for label, codes in (("added", report.added), ("updated", report.updated), ("deactivated", report.deactivated)):
        if codes:
            print(f"  {label}: {', '.join(codes[:50])}{' ...' if len(codes) > 50 else ''}")
    for _, reason in report.invalid:
        print(f"  skipped {reason}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
