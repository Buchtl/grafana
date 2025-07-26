#!/bin/bash
set -e

# Wait for Postgres to be ready
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for Postgres..."
  sleep 2
done

# Restore dump (custom format)
pg_restore --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB" /docker-entrypoint-initdb.d/appdb.dump
