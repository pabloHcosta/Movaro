#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ENV_FILE="${SOURCE_ENV_FILE:-$ROOT_DIR/.env.production.json}"
OUTPUT_ENV_FILE="${OUTPUT_ENV_FILE:-$ROOT_DIR/.env.production.local.json}"
LOCAL_API_URL="${LOCAL_API_URL:-http://localhost:3000}"
TMP_DIR="$ROOT_DIR/.tmp/cloudflare"
LOG_FILE="$TMP_DIR/tunnel.log"
PID_FILE="$TMP_DIR/tunnel.pid"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-25}"

mkdir -p "$TMP_DIR"

if [[ ! -f "$SOURCE_ENV_FILE" ]]; then
  echo "Source env file not found: $SOURCE_ENV_FILE" >&2
  exit 1
fi

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared is not installed or not in PATH." >&2
  exit 1
fi

print_section() {
  printf '\n[%s]\n' "$1"
}

stop_existing_tunnel() {
  if [[ -f "$PID_FILE" ]]; then
    local previous_pid
    previous_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [[ -n "$previous_pid" ]] && kill -0 "$previous_pid" 2>/dev/null; then
      kill "$previous_pid" 2>/dev/null || true
      wait "$previous_pid" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
  fi
}

extract_tunnel_url() {
  if [[ ! -f "$LOG_FILE" ]]; then
    return 1
  fi

  python3 - "$LOG_FILE" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8", errors="ignore") as fh:
    content = fh.read()

match = re.search(r"https://[a-z0-9-]+\.trycloudflare\.com", content, re.I)
if match:
    print(match.group(0))
PY
}

wait_for_tunnel_url() {
  local started_at
  started_at="$(date +%s)"

  while true; do
    local url
    url="$(extract_tunnel_url || true)"
    if [[ -n "$url" ]]; then
      printf '%s\n' "$url"
      return 0
    fi

    local now
    now="$(date +%s)"
    if (( now - started_at >= MAX_WAIT_SECONDS )); then
      echo "Timed out waiting for Cloudflare Tunnel URL." >&2
      return 1
    fi

    sleep 1
  done
}

write_env_file() {
  local public_url="$1"

  node - "$SOURCE_ENV_FILE" "$OUTPUT_ENV_FILE" "$public_url" <<'NODE'
const fs = require('fs');

const [sourcePath, outputPath, publicUrl] = process.argv.slice(2);
const env = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
env.API_SOURCE = 'local';
env.LOCAL_API_BASE_URL = publicUrl;
fs.writeFileSync(outputPath, `${JSON.stringify(env, null, 2)}\n`);
NODE
}

validate_public_url() {
  local public_url="$1"
  local attempts=0
  until curl -fsS --max-time 20 "$public_url/api/v1/health" >/dev/null; do
    attempts=$((attempts + 1))
    if (( attempts >= 10 )); then
      echo "Warning: tunnel URL did not become reachable in time: $public_url" >&2
      return 0
    fi
    sleep 2
  done
}

print_section "Validating local API"
curl -fsS --max-time 10 "$LOCAL_API_URL/api/v1/health" >/dev/null
echo "Local API is reachable at $LOCAL_API_URL"

print_section "Starting Cloudflare Tunnel"
stop_existing_tunnel
rm -f "$LOG_FILE"
nohup cloudflared tunnel --url "$LOCAL_API_URL" >"$LOG_FILE" 2>&1 &
TUNNEL_PID=$!
echo "$TUNNEL_PID" >"$PID_FILE"

PUBLIC_URL="$(wait_for_tunnel_url)"
validate_public_url "$PUBLIC_URL"
write_env_file "$PUBLIC_URL"

print_section "Local production env ready"
echo "Tunnel URL: $PUBLIC_URL"
echo "Env file: $OUTPUT_ENV_FILE"
echo "Tunnel PID: $TUNNEL_PID"
echo "Tunnel log: $LOG_FILE"
