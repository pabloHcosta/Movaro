#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE_OVERRIDE:-$ROOT_DIR/.env.production.json}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Production env file not found: $ENV_FILE" >&2
  exit 1
fi

API_BASE_URL="$(
  node -e '
    const env = require(process.argv[1]);
    const source = process.env.API_SOURCE || env.API_SOURCE || "railway";
    const resolved =
      env.API_BASE_URL ||
      (source === "local" ? env.LOCAL_API_BASE_URL : env.RAILWAY_API_BASE_URL);

    if (!resolved) {
      process.exit(1);
    }

    process.stdout.write(resolved);
  ' "$ENV_FILE"
)"

if [[ -z "$API_BASE_URL" || "$API_BASE_URL" == "undefined" ]]; then
  echo "Resolved API base URL missing in $ENV_FILE" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

print_section() {
  printf '\n[%s]\n' "$1"
}

request() {
  local name="$1"
  local method="$2"
  local path="$3"
  local expected_codes="$4"
  local body="${5:-}"

  local response_file="$TMP_DIR/response.txt"
  local status_file="$TMP_DIR/status.txt"
  local curl_args=(
    -sS
    --max-time 25
    -o "$response_file"
    -w "%{http_code}"
    -X "$method"
  )

  if [[ -n "$body" ]]; then
    curl_args+=(
      -H "Content-Type: application/json"
      -d "$body"
    )
  fi

  local status
  status="$(curl "${curl_args[@]}" "$API_BASE_URL$path")"
  printf '%s' "$status" > "$status_file"

  if [[ " $expected_codes " != *" $status "* ]]; then
    echo "FAIL $name -> HTTP $status"
    cat "$response_file"
    exit 1
  fi

  if ! grep -q '"success":true' "$response_file"; then
    echo "FAIL $name -> success=false"
    cat "$response_file"
    exit 1
  fi

  echo "OK   $name -> HTTP $status"
}

print_section "Checking production API"
echo "Base URL: $API_BASE_URL"

request "health" "GET" "/api/v1/health" "200"
request "exchange rates" "GET" "/api/v1/reference/exchange-rates/current" "200"
request "cities methodology" "GET" "/api/v1/cities/metadata/methodology" "200"
request "cities catalog" "GET" "/api/v1/cities" "200"
request "cities highlights" "GET" "/api/v1/cities/highlights" "200"
request "cities search" "GET" "/api/v1/cities/search?q=sao" "200"
request "city detail" "GET" "/api/v1/cities/sao-paulo-sp" "200"
request "city weather" "GET" "/api/v1/cities/sao-paulo-sp/weather" "200"
request \
  "migration plan" \
  "POST" \
  "/api/v1/migration/plan" \
  "200 201" \
  '{"originCountry":"Argentina","destinationCountry":"Brasil","goal":"Trabalhar","timeline":"Nos proximos 6 meses"}'

print_section "Production API passed"
echo "All checked endpoints responded successfully."
