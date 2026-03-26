#!/usr/bin/env bash

set -euo pipefail

LOCAL_API_URL="${LOCAL_API_URL:-http://localhost:3000}"

echo "[Cloudflare Tunnel]"
echo "Forwarding public traffic to: $LOCAL_API_URL"
echo "Keep this terminal open while using the temporary public URL."
echo

exec cloudflared tunnel --url "$LOCAL_API_URL"
