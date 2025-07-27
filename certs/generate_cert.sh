#!/usr/bin/env bash
set -euo pipefail

# ---- error handling ---------------------------------------------------------
on_error() {
  echo "❌ Error on line $1" >&2
  exit 1
}
trap 'on_error $LINENO' ERR

# ---- defaults ---------------------------------------------------------------
CA_DIR="./"
CA_CN="Dev Local Root CA"
DAYS_LEAF=825
DAYS_CA=3650
OPENSSL_BIN="${OPENSSL_BIN:-openssl}"

DNS_CSV=""
IP_CSV=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <common-name> -d "dns1,dns2[,*.example.test]" [-i "ip1,ip2"] [-C <ca_dir>] [-n <ca_cn>]

Options:
  -d  Comma-separated DNS SANs (required)
  -i  Comma-separated IP SANs (optional)
  -C  Directory to store the local root CA (default: .devca)
  -n  Common Name for the local root CA (default: "Dev Local Root CA")
  -h  Show this help

Examples:
  $(basename "$0") my.dev.local -d "localhost,my.dev.local,*.example.test" -i "127.0.0.1,::1"
  $(basename "$0") api.internal -d "api.internal" -C "./ca" -n "My Dev CA"
EOF
}

# ---- arg parsing ------------------------------------------------------------
if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

CN="$1"; shift

while getopts ":d:i:C:n:h" opt; do
  case "$opt" in
    d) DNS_CSV="$OPTARG" ;;
    i) IP_CSV="$OPTARG" ;;
    C) CA_DIR="$OPTARG" ;;
    n) CA_CN="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
    \?) echo "Unknown option -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$DNS_CSV" ]]; then
  echo "[-] -d <dns1,dns2,...> is required." >&2
  usage
  exit 1
fi

IFS=',' read -r -a DNS_SANS <<< "$DNS_CSV"
IP_SANS=()
if [[ -n "$IP_CSV" ]]; then
  IFS=',' read -r -a IP_SANS <<< "$IP_CSV"
fi

# ---- functions --------------------------------------------------------------
ensure_ca() {
  if [[ ! -f "${CA_DIR}/ca.key.pem" || ! -f "${CA_DIR}/ca.crt.pem" ]]; then
    echo "[*] Creating local root CA in ${CA_DIR}"
    mkdir -p "${CA_DIR}"
    ${OPENSSL_BIN} genrsa -out "${CA_DIR}/ca.key.pem" 4096
    ${OPENSSL_BIN} req -x509 -new -nodes \
      -key "${CA_DIR}/ca.key.pem" \
      -sha256 -days "${DAYS_CA}" \
      -subj "/CN=${CA_CN}" \
      -out "${CA_DIR}/ca.crt.pem"
    echo "[*] Root CA created: ${CA_DIR}/ca.crt.pem"
    echo "    -> Import/trust this root CA in your OS/browser once."
  else
    echo "[*] Using existing root CA in ${CA_DIR}"
  fi
}

generate_cert() {
  cn="$1"

  tmpconf="$(mktemp)"
  tmpext="$(mktemp)"
  trap 'rm -f "$tmpconf" "$tmpext" "$cn.csr.pem" "${CA_DIR}/ca.crt.pem.srl" 2>/dev/null || true' EXIT

  # openssl req config
  {
    echo "[req]"
    echo "default_bits = 2048"
    echo "prompt = no"
    echo "default_md = sha256"
    echo "distinguished_name = dn"
    echo "req_extensions = req_ext"
    echo
    echo "[dn]"
    echo "CN = ${cn}"
    echo
    echo "[req_ext]"
    echo "subjectAltName = @alt_names"
    echo
    echo "[alt_names]"
    local i=1
    for dns in "${DNS_SANS[@]}"; do
      echo "DNS.$i = $dns"
      ((i++))
    done
    for ip in "${IP_SANS[@]}"; do
      echo "IP.$i = $ip"
      ((i++))
    done
  } > "$tmpconf"

  # x509 extfile
  {
    echo "basicConstraints = CA:FALSE"
    echo "keyUsage = digitalSignature, keyEncipherment"
    echo "extendedKeyUsage = serverAuth, clientAuth"
    echo "subjectAltName = @alt_names"
    echo
    echo "[alt_names]"
    local i=1
    for dns in "${DNS_SANS[@]}"; do
      echo "DNS.$i = $dns"
      ((i++))
    done
    for ip in "${IP_SANS[@]}"; do
      echo "IP.$i = $ip"
      ((i++))
    done
  } > "$tmpext"

  echo "[*] Generating key and CSR for ${cn}"
  ${OPENSSL_BIN} genrsa -out "${cn}.key.pem" 2048
  ${OPENSSL_BIN} req -new -key "${cn}.key.pem" -out "${cn}.csr.pem" -config "$tmpconf"

  echo "[*] Signing certificate with local root CA"
  ${OPENSSL_BIN} x509 -req \
    -in "${cn}.csr.pem" \
    -CA "${CA_DIR}/ca.crt.pem" \
    -CAkey "${CA_DIR}/ca.key.pem" \
    -CAcreateserial \
    -out "${cn}.crt.pem" \
    -days "${DAYS_LEAF}" \
    -sha256 \
    -extfile "$tmpext"

  echo "[+] Done."
  echo "    Key:  ${cn}.key.pem"
  echo "    Cert: ${cn}.crt.pem"
  echo "    CA:   ${CA_DIR}/ca.crt.pem (import/trust once)"
}

# ---- run --------------------------------------------------------------------
ensure_ca
generate_cert "$CN"
