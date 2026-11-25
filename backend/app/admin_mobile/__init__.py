"""JSON API for the AdvocateMate Admin phone app (Android / iOS), served at /admin-mobile/v1.

Separate from the browser Admin App API (/admin-api/v1, cookie + CSRF), which stays unchanged: phones send a
bearer access token, so no cookies, CSRF tokens or Origin checks are involved. Accounts, roles, permissions,
Google verification, session limits and the audit trail are the shared ones (``app.services.admin_access``,
``app.admin.guards``, ``app.admin.permissions``).
"""
