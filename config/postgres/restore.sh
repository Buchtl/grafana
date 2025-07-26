#!/bin/bash
set -e

# Wait for Postgres to be ready
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for Postgres..."
  sleep 2
done

# Restore dump (custom format)
#FILE_TO_RESTORE="appdb.sql"
#psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "/docker-entrypoint-initdb.d/$FILE_TO_RESTORE"

#DUMP
pg_restore --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB" /docker-entrypoint-initdb.d/appdb.dump
