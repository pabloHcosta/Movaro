#!/usr/bin/env bash

set -euo pipefail

LOCAL_API_URL="${LOCAL_API_URL:-http://localhost:3000}"
TUNNEL_MODE="${TUNNEL_MODE:-named}"

echo "[Cloudflare Tunnel]"
if [[ "$TUNNEL_MODE" == "named" ]]; then
  if [[ -z "${TUNNEL_NAME:-}" ]]; then
    echo "Set TUNNEL_NAME to your named Tunnel's name or UUID." >&2
    exit 1
  fi
  echo "Starting named Tunnel: $TUNNEL_NAME"
  exec cloudflared tunnel run "$TUNNEL_NAME"
elif [[ "$TUNNEL_MODE" == "quick" ]]; then
  echo "Forwarding public traffic to: $LOCAL_API_URL"
  echo "Keep this terminal open while using the temporary public URL."
  exec cloudflared tunnel --url "$LOCAL_API_URL"
else
  echo "TUNNEL_MODE must be named or quick." >&2
  exit 1
fi
