#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/.env.production.local.json}"
DEVICE_ID="${DEVICE_ID:-}"

bash "$ROOT_DIR/scripts/prepare_local_production_env.sh"

FLUTTER_ARGS=(
  "run"
  "--target"
  "lib/main_production.dart"
  "--dart-define-from-file=$LOCAL_ENV_FILE"
)

if [[ -n "$DEVICE_ID" ]]; then
  FLUTTER_ARGS+=("-d" "$DEVICE_ID")
fi

(
  cd "$ROOT_DIR"
  flutter "${FLUTTER_ARGS[@]}"
)
