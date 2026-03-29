#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_ENV_FILE="${LOCAL_ENV_FILE:-$ROOT_DIR/.env.production.local.json}"
BUILD_MODE="${BUILD_MODE:-release}"

if [[ "$BUILD_MODE" != "release" && "$BUILD_MODE" != "debug" ]]; then
  echo "BUILD_MODE must be 'release' or 'debug'. Received: $BUILD_MODE" >&2
  exit 1
fi

bash "$ROOT_DIR/scripts/prepare_local_production_env.sh"

FLUTTER_ARGS=(
  "build"
  "ios"
  "--$BUILD_MODE"
  "--target"
  "lib/main_production.dart"
  "--dart-define-from-file=$LOCAL_ENV_FILE"
)

(
  cd "$ROOT_DIR"
  flutter "${FLUTTER_ARGS[@]}"
)
