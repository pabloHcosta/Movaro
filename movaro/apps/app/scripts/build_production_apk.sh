#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE_OVERRIDE:-$ROOT_DIR/.env.production.json}"
API_SOURCE_OVERRIDE="${API_SOURCE:-}"
BUILD_MODE="${BUILD_MODE:-release}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Production env file not found: $ENV_FILE" >&2
  exit 1
fi

if [[ "$BUILD_MODE" != "release" && "$BUILD_MODE" != "debug" ]]; then
  echo "BUILD_MODE must be 'release' or 'debug'. Received: $BUILD_MODE" >&2
  exit 1
fi

print_section() {
  printf '\n[%s]\n' "$1"
}

prefer_java_17() {
  local preferred_java_home=""

  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    preferred_java_home="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
  fi

  if [[ -z "$preferred_java_home" ]] && command -v brew >/dev/null 2>&1; then
    local brew_prefix=""
    brew_prefix="$(brew --prefix openjdk@17 2>/dev/null || true)"
    if [[ -n "$brew_prefix" && -d "$brew_prefix/libexec/openjdk.jdk/Contents/Home" ]]; then
      preferred_java_home="$brew_prefix/libexec/openjdk.jdk/Contents/Home"
    fi
  fi

  if [[ -z "$preferred_java_home" ]]; then
    return 0
  fi

  export JAVA_HOME="$preferred_java_home"
  export PATH="$JAVA_HOME/bin:$PATH"
}

resolve_api_source() {
  node -e '
    const env = require(process.argv[1]);
    const source = process.env.API_SOURCE || env.API_SOURCE || "railway";
    process.stdout.write(source);
  ' "$ENV_FILE"
}

resolve_output_path() {
  case "$BUILD_MODE" in
    release)
      printf '%s\n' "$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
      ;;
    debug)
      printf '%s\n' "$ROOT_DIR/build/app/outputs/flutter-apk/app-debug.apk"
      ;;
  esac
}

FLUTTER_ARGS=(
  "build"
  "apk"
  "--$BUILD_MODE"
  "--target"
  "lib/main_production.dart"
  "--dart-define-from-file=$ENV_FILE"
)

if [[ -n "$API_SOURCE_OVERRIDE" ]]; then
  FLUTTER_ARGS+=("--dart-define=API_SOURCE=$API_SOURCE_OVERRIDE")
fi

print_section "Validating production API"
if [[ -n "$API_SOURCE_OVERRIDE" ]]; then
  API_SOURCE="$API_SOURCE_OVERRIDE" bash "$ROOT_DIR/scripts/validate_production_api.sh"
else
  bash "$ROOT_DIR/scripts/validate_production_api.sh"
fi

print_section "Building APK"
prefer_java_17
echo "Build mode: $BUILD_MODE"
echo "API source: $(resolve_api_source)"
if [[ -n "${JAVA_HOME:-}" ]]; then
  echo "JAVA_HOME: $JAVA_HOME"
fi
if [[ -n "$API_SOURCE_OVERRIDE" ]]; then
  echo "API source override: $API_SOURCE_OVERRIDE"
fi

(
  cd "$ROOT_DIR"
  flutter "${FLUTTER_ARGS[@]}"
)

OUTPUT_PATH="$(resolve_output_path)"

if [[ ! -f "$OUTPUT_PATH" ]]; then
  echo "APK build finished but output was not found at: $OUTPUT_PATH" >&2
  exit 1
fi

print_section "APK generated"
echo "$OUTPUT_PATH"
