#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/.env.production.local.json}"

bash "$ROOT_DIR/scripts/prepare_local_production_env.sh"

ENV_FILE_OVERRIDE="$LOCAL_ENV_FILE" API_SOURCE=local bash \
  "$ROOT_DIR/scripts/build_production_apk.sh"
