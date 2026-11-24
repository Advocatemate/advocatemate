"""JSON API for the separate AdvocateMate Admin web app, served at /admin-api/v1.

The Admin App is its own project and deployment; it reaches this API only through its reverse proxy, on the
same origin as the app, so the admin session cookie stays first-party and no CORS is involved. Sign-in,
sessions, roles and audit reuse ``app.services.admin_access``, ``app.admin.guards`` and
``app.admin.permissions`` - the same rules as the server-rendered portal at /admin.
"""
