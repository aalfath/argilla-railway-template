# Changelog

Deployers: read the entry for the version you're updating to before you apply an update in Railway.

## 2.8.0 (2026-11-18)

- First release: Argilla server v2.8.0 and its background worker (`argilla/argilla-server:v2.8.0`, pinned by digest), Elasticsearch 8.19.25 (pinned by digest, security on, data on a volume), Railway Postgres 18 and Redis 8.2.
- The owner account `admin` is created on the first start with a generated password and API key.
- The server listens on `0.0.0.0` (uvicorn's `::` binds IPv6 only and breaks container-local checks). Health check: `/api/v1/version` (`/api/v1/status` returns 422 against Elasticsearch 8.19 in Argilla 2.8.0).
