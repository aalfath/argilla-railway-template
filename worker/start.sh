#!/bin/bash
# Start script for the Argilla background worker on Railway.
set -e
case "$ARGILLA_DATABASE_URL" in
  postgres://*) export ARGILLA_DATABASE_URL="postgresql+asyncpg://${ARGILLA_DATABASE_URL#postgres://}" ;;
  postgresql://*) export ARGILLA_DATABASE_URL="postgresql+asyncpg://${ARGILLA_DATABASE_URL#postgresql://}" ;;
esac
exec python -m argilla_server worker --num-workers "${BACKGROUND_NUM_WORKERS:-2}"
