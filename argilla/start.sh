#!/bin/bash
# Start script for the Argilla server on Railway.
# Same steps as the upstream start_argilla_server.sh (v2.8.0), plus Railway's PORT
# and a check that the owner credentials were generated.
set -e

export UVICORN_PORT="${PORT:-6900}"
export USERNAME="${USERNAME:-admin}"
export WORKSPACE="${WORKSPACE-default}"

if [ -z "$PASSWORD" ] || [ -z "$API_KEY" ]; then
  echo "railway-template: PASSWORD and API_KEY must be set; refusing to start without them" >&2
  exit 1
fi
if [ -z "$ARGILLA_DATABASE_URL" ] || [ -z "$ARGILLA_ELASTICSEARCH" ] || [ -z "$ARGILLA_REDIS_URL" ]; then
  echo "railway-template: ARGILLA_DATABASE_URL, ARGILLA_ELASTICSEARCH and ARGILLA_REDIS_URL must be set" >&2
  exit 1
fi

# Railway's Postgres hands out postgresql:// URLs; Argilla wants the asyncpg driver.
case "$ARGILLA_DATABASE_URL" in
  postgres://*) export ARGILLA_DATABASE_URL="postgresql+asyncpg://${ARGILLA_DATABASE_URL#postgres://}" ;;
  postgresql://*) export ARGILLA_DATABASE_URL="postgresql+asyncpg://${ARGILLA_DATABASE_URL#postgresql://}" ;;
esac

# Elasticsearch may still be starting on a fresh deploy: wait up to 5 minutes.
python - <<'PY'
import os, sys, time, urllib.request, urllib.parse, base64
u = urllib.parse.urlsplit(os.environ["ARGILLA_ELASTICSEARCH"])
url = f"{u.scheme}://{u.hostname if ':' not in (u.hostname or '') else '[' + u.hostname + ']'}:{u.port or 9200}/_cluster/health"
req = urllib.request.Request(url)
if u.username:
    tok = base64.b64encode(f"{urllib.parse.unquote(u.username)}:{urllib.parse.unquote(u.password or '')}".encode()).decode()
    req.add_header("Authorization", "Basic " + tok)
for i in range(60):
    try:
        urllib.request.urlopen(req, timeout=5).read()
        print("railway-template: Elasticsearch is up", flush=True)
        sys.exit(0)
    except Exception as e:
        if i % 6 == 0:
            print(f"railway-template: waiting for Elasticsearch ({type(e).__name__})", flush=True)
        time.sleep(5)
print("railway-template: Elasticsearch did not answer in 5 minutes; starting anyway", flush=True)
PY

python -m argilla_server database migrate

# Creates the owner on the first start; later starts print "already exists" and skip.
cmd_args=(--first-name "$USERNAME" --username "$USERNAME" --password "$PASSWORD" --role owner --api-key "$API_KEY")
if [ -n "$WORKSPACE" ]; then
  cmd_args+=(--workspace "$WORKSPACE")
fi
python -m argilla_server database users create "${cmd_args[@]}" | grep -v -i -E 'api_key|password' || true

if [ "$REINDEX_DATASETS" = "true" ] || [ "$REINDEX_DATASETS" = "1" ]; then
  echo "railway-template: reindexing existing datasets"
  python -m argilla_server search-engine reindex
fi

exec python -m uvicorn "$UVICORN_APP" --host "::" --port "$UVICORN_PORT" --proxy-headers --forwarded-allow-ips "*"
