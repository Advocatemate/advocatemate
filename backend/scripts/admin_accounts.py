"""Manage admin-portal accounts from the command line (needed for the first owner: there is no sign-up).

    python -m scripts.admin_accounts add owner@example.com --role owner
    python -m scripts.admin_accounts list
    python -m scripts.admin_accounts set-role someone@example.com admin
    python -m scripts.admin_accounts deactivate someone@example.com
    python -m scripts.admin_accounts activate someone@example.com

Run from the backend folder with the environment (DATABASE_URL, ...) loaded. Every change is audited.
"""

from __future__ import annotations

import argparse
import sys

from app.db.session import db_session
from app.models import ADMIN_ROLES
from app.services import admin_access


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m scripts.admin_accounts", description=__doc__.split("\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)
    add = sub.add_parser("add", help="authorise a Google account")
    add.add_argument("email")
    add.add_argument("--role", choices=ADMIN_ROLES, required=True)
    sub.add_parser("list", help="list admin accounts")
    sr = sub.add_parser("set-role", help="change an admin's role")
    sr.add_argument("email")
    sr.add_argument("role", choices=ADMIN_ROLES)
    for name in ("deactivate", "activate"):
        p = sub.add_parser(name, help=f"{name} an admin account")
        p.add_argument("email")
    args = parser.parse_args(argv)

    try:
        with db_session() as db:
            if args.command == "add":
                acct = admin_access.create_account(db, args.email, args.role, via="cli")
                print(f"Added {acct.email} as {acct.role}. They can now sign in at /admin with Google.")
            elif args.command == "list":
                rows = admin_access.list_accounts(db)
                if not rows:
                    print("No admin accounts yet. Add the first owner with: add <email> --role owner")
                for a in rows:
                    state = "active" if a.is_active else "inactive"
                    print(f"{a.email:40} {a.role:8} {state:9} last sign-in: {a.last_login_at or '-'}")
            else:
                acct = admin_access.get_by_email(db, args.email)
                if acct is None:
                    print(f"No admin account for {args.email}.", file=sys.stderr)
                    return 1
                if args.command == "set-role":
                    admin_access.set_role(db, acct, args.role, by=None)
                    print(f"{acct.email} is now {acct.role}.")
                else:
                    admin_access.set_active(db, acct, args.command == "activate", by=None)
                    print(f"{acct.email} {'activated' if acct.is_active else 'deactivated'}.")
    except admin_access.AdminAccessError as e:
        print(e.message, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
