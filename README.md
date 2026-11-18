[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/argilla?utm_medium=integration&utm_source=button&utm_campaign=argilla)

# Argilla on Railway

A one-click [Railway](https://railway.com) template for [Argilla](https://github.com/argilla-io/argilla), the open-source (Apache-2.0) tool for building and annotating datasets for AI models.

| Service | Source | Image (pinned by version and digest) | Volume |
|---|---|---|---|
| Argilla (public) | `argilla/` in this repo | `argilla/argilla-server:v2.8.0@sha256:6f4af8fcf4b809d25aa88a6a4f8838dbacab9296c83b055a9a58f1db7526431a` | none: state lives in Postgres and Elasticsearch |
| Worker (private) | `worker/` in this repo | same image as Argilla | none |
| Elasticsearch (private) | `elasticsearch/` in this repo | `elastic/elasticsearch:8.19.25@sha256:5bfdf4313b9bc05c0d46fe219d6e67710eb0c7654ed6c275167bdf9beefc56f0` | `/usr/share/elasticsearch/data` |
| Postgres (private) | Railway's Postgres | `ghcr.io/railwayapp-templates/postgres-ssl:18` | `/var/lib/postgresql/data` |
| Redis (private) | Railway's Redis | `redis:8.2` | `/data` |

Argilla, Worker and Elasticsearch build from this repo, so Railway tells everyone who deployed the template when a new version lands on `main`.

## What you get

- Argilla 2.8.0 (the latest release) on a public HTTPS domain, with its login page.
- The owner account `admin` is created on the first start with a generated password and API key, in a workspace named `default`. Nobody can use the app without logging in.
- The background worker that Argilla 2.x needs for dataset imports and exports from the Hugging Face Hub, webhooks and annotation progress.
- Users, datasets and annotations in Postgres and the search index in Elasticsearch, each on a volume, so they survive redeploys and restarts.
- Elasticsearch 8.19 with security on, a generated `elastic` password and no public domain. Only its cluster health answers without a login (used by Railway's health check).
- Health checks: Argilla `/api/v1/version`, Elasticsearch `/_cluster/health`.

## After deploying

1. Wait for all five services to turn green (about 3 to 5 minutes on the first deploy).
2. Open the Argilla service's domain and log in as `admin` with the `PASSWORD` shown in the **Argilla** service's Variables tab.
3. Connect from Python with the `API_KEY` from the same tab:
   ```python
   import argilla as rg
   client = rg.Argilla(api_url="https://YOUR-DOMAIN", api_key="YOUR-API-KEY")
   ```
4. Add annotators from the SDK or the CLI (`rg.User(username=..., password=..., role="annotator").create()`), and give them access to a workspace.

## Variables

| Service | Variable | Default | Notes |
|---|---|---|---|
| Argilla | `USERNAME` | `admin` | Owner account created on the first start. |
| Argilla | `PASSWORD` | generated | The owner's password, set only when the owner is first created. Change it later in Argilla, not here. |
| Argilla | `API_KEY` | generated | The owner's API key for the Python SDK, also set only on the first start. |
| Argilla | `ARGILLA_AUTH_SECRET_KEY` | generated | Signs login tokens; keeps users logged in across redeploys. |
| Argilla | `PORT` | `6900` | |
| Argilla, Worker | `ARGILLA_DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | The start scripts switch it to the `asyncpg` driver. |
| Argilla, Worker | `ARGILLA_REDIS_URL` | `${{Redis.REDIS_URL}}` | |
| Argilla, Worker | `ARGILLA_ELASTICSEARCH` | private URL with the `elastic` password | Reference variable. |
| Worker | `BACKGROUND_NUM_WORKERS` | `2` | Number of job workers. |
| Elasticsearch | `ELASTIC_PASSWORD` | generated | Stored on the first start; changing it later has no effect. |
| Elasticsearch | `ES_JAVA_OPTS` | `-Xms512m -Xmx512m` | Java heap; keep it at about half of the memory the service gets. |
| Elasticsearch | `PORT` | `9200` | Private network only. |

Optional, not set by default: Hugging Face OAuth sign-in (`ARGILLA_AUTH_OAUTH_CFG`, see [Argilla's docs](https://docs.argilla.io/latest/getting_started/how-to-configure-argilla-on-huggingface/)), `HF_HUB_DISABLE_TELEMETRY=1` to turn off Argilla's anonymous usage telemetry, and `REINDEX_DATASETS=1` (one deploy only) to rebuild the search index from Postgres.

## Updates

Version bumps land on `main` with an entry in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Railway then shows an "update available" notice in your project, and you choose when to apply it. Argilla migrates its database schema on start, so back up Postgres before applying an update. Argilla's original authors announced in 2025 that the project is in maintenance mode: bug fixes and patches, no new features.

## Local test

Each folder builds with plain `docker build`. The scripts expect the variables above; `argilla/start.sh` refuses to start without `PASSWORD` and `API_KEY`.
