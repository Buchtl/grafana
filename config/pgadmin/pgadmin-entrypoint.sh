#!/bin/sh
export PGADMIN_DEFAULT_PASSWORD="$(cat /run/secrets/pgadmin_admin_password)"
exec /entrypoint.sh "$@"
