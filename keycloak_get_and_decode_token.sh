#!/usr/bin/env bash
set -euo pipefail

# ------------ Config ------------
url=$(hostname -I | awk '{print $1}')
port="8083"
username="admin"
password="admin"
realm="grafana"
client="grafana"
client_secret="FA7eOmIpkog7ggBvKAzA6KjDnIYEKHlk"
# --------------------------------

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing dependency: $1" >&2
    exit 1
  }
}
need jq

echo "Requesting token from Keycloak at http://$url:$port/realms/$realm/protocol/openid-connect/token ..." >&2

RESP_JSON="$(
  curl -sS --location --request POST "http://$url:$port/realms/$realm/protocol/openid-connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "client_id=$client" \
    --data-urlencode "client_secret=$client_secret" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode "username=$username" \
    --data-urlencode "password=$password"
)"

# Basic sanity check
if ! echo "$RESP_JSON" | jq -e . >/dev/null 2>&1; then
  echo "Server did not return JSON. Raw response:" >&2
  echo "$RESP_JSON" >&2
  exit 1
fi

# Extract tokens (may be empty / null)
ACCESS_TOKEN=$(echo "$RESP_JSON" | jq -r '.access_token // empty')
ID_TOKEN=$(echo "$RESP_JSON" | jq -r '.id_token // empty')
REFRESH_TOKEN=$(echo "$RESP_JSON" | jq -r '.refresh_token // empty')

if [[ -z "$ACCESS_TOKEN" && -z "$ID_TOKEN" && -z "$REFRESH_TOKEN" ]]; then
  echo "No tokens found in response:" >&2
  echo "$RESP_JSON" | jq .
  exit 1
fi

decode_jwt() {
  local token="$1"
  local name="$2"

  [[ -z "$token" ]] && return

  echo "==================== $name ===================="

  # Header
  echo "----- Header -----"
  echo "$token" | jq -R 'split(".") | .[0] | @base64d | fromjson'

  # Payload
  echo
  echo "----- Payload ----"
  PAYLOAD_JSON="$(echo "$token" | jq -R 'split(".") | .[1] | @base64d | fromjson')"
  echo "$PAYLOAD_JSON" | jq .

  # Signature
  echo
  echo "----- Signature (base64url) -----"
  echo "$token" | jq -R 'split(".") | .[2]'

  # Friendly timestamps
  echo
  echo "----- Timestamps (human) -----"
  exp=$(echo "$PAYLOAD_JSON" | jq -r 'try .exp // empty')
  iat=$(echo "$PAYLOAD_JSON" | jq -r 'try .iat // empty')
  nbf=$(echo "$PAYLOAD_JSON" | jq -r 'try .nbf // empty')

  ts() {
    [[ -n "$1" && "$1" != "null" ]] && date -d @"$1" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || true
  }

  [[ -n "$iat" ]] && echo "iat: $iat ($(ts "$iat"))"
  [[ -n "$nbf" ]] && echo "nbf: $nbf ($(ts "$nbf"))"
  [[ -n "$exp" ]] && echo "exp: $exp ($(ts "$exp"))"

  echo
}

decode_jwt "$ACCESS_TOKEN"  "ACCESS TOKEN"
decode_jwt "$ID_TOKEN"      "ID TOKEN"
decode_jwt "$REFRESH_TOKEN" "REFRESH TOKEN"

echo "Done."
