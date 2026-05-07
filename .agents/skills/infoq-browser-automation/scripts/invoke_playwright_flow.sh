#!/usr/bin/env sh
set -eu

print_help() {
  cat <<'EOF'
Usage:
  sh .agents/skills/infoq-browser-automation/scripts/invoke_playwright_flow.sh --url <url> [options]

Options:
  --url <url>
  --storage-key <key>
  --storage-value <value>
  --wait-for-text <text>
  --wait-for-url <pattern>
  --screenshot-path <path>
  --console-log-path <path>
  --timeout-ms <ms>
  --headed
  --ignore-https-errors
  --allow-console-errors
  --help
EOF
}

require_value() {
  flag=$1
  value=${2-}
  case "$value" in
    ""|--*)
      echo "Missing value for $flag." >&2
      exit 1
      ;;
  esac
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../../../.." && pwd)

URL=""
STORAGE_KEY="Admin-Token"
STORAGE_VALUE=""
WAIT_FOR_TEXT=""
WAIT_FOR_URL=""
SCREENSHOT_PATH=""
CONSOLE_LOG_PATH=""
TIMEOUT_MS="45000"
HEADED=0
IGNORE_HTTPS_ERRORS=0
ALLOW_CONSOLE_ERRORS=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --url)
      require_value "$1" "${2-}"
      URL=$2
      shift 2
      ;;
    --storage-key)
      require_value "$1" "${2-}"
      STORAGE_KEY=$2
      shift 2
      ;;
    --storage-value)
      require_value "$1" "${2-}"
      STORAGE_VALUE=$2
      shift 2
      ;;
    --wait-for-text)
      require_value "$1" "${2-}"
      WAIT_FOR_TEXT=$2
      shift 2
      ;;
    --wait-for-url)
      require_value "$1" "${2-}"
      WAIT_FOR_URL=$2
      shift 2
      ;;
    --screenshot-path)
      require_value "$1" "${2-}"
      SCREENSHOT_PATH=$2
      shift 2
      ;;
    --console-log-path)
      require_value "$1" "${2-}"
      CONSOLE_LOG_PATH=$2
      shift 2
      ;;
    --timeout-ms)
      require_value "$1" "${2-}"
      TIMEOUT_MS=$2
      shift 2
      ;;
    --headed)
      HEADED=1
      shift
      ;;
    --ignore-https-errors)
      IGNORE_HTTPS_ERRORS=1
      shift
      ;;
    --allow-console-errors)
      ALLOW_CONSOLE_ERRORS=1
      shift
      ;;
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_help >&2
      exit 1
      ;;
  esac
done

if [ -z "$URL" ]; then
  echo "--url is required." >&2
  print_help >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required but was not found in PATH." >&2
  exit 1
fi

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
if [ -z "$SCREENSHOT_PATH" ]; then
  SCREENSHOT_PATH="$REPO_ROOT/test-results/browser-automation/$TIMESTAMP.png"
fi
if [ -z "$CONSOLE_LOG_PATH" ]; then
  CONSOLE_LOG_PATH="$REPO_ROOT/test-results/browser-automation/$TIMESTAMP.console.json"
fi

echo "[browser-flow] url: $URL"
echo "[browser-flow] screenshot: $SCREENSHOT_PATH"
echo "[browser-flow] console log: $CONSOLE_LOG_PATH"

set -- run playwright-cli flow \
  --url "$URL" \
  --storage-key "$STORAGE_KEY" \
  --timeout-ms "$TIMEOUT_MS" \
  --screenshot-path "$SCREENSHOT_PATH" \
  --console-log-path "$CONSOLE_LOG_PATH"

if [ -n "$STORAGE_VALUE" ]; then
  set -- "$@" --storage-value "$STORAGE_VALUE"
fi
if [ -n "$WAIT_FOR_TEXT" ]; then
  set -- "$@" --wait-for-text "$WAIT_FOR_TEXT"
fi
if [ -n "$WAIT_FOR_URL" ]; then
  set -- "$@" --wait-for-url "$WAIT_FOR_URL"
fi
if [ "$HEADED" -eq 1 ]; then
  set -- "$@" --headed
fi
if [ "$IGNORE_HTTPS_ERRORS" -eq 1 ]; then
  set -- "$@" --ignore-https-errors
fi
if [ "$ALLOW_CONSOLE_ERRORS" -eq 1 ]; then
  set -- "$@" --allow-console-errors
fi

if ! (
  cd "$SCRIPT_DIR"
  pnpm "$@"
); then
  echo "Playwright flow failed. Ensure dependencies are installed via 'pnpm --dir .agents/skills/infoq-browser-automation/scripts install' and install Chromium via 'pnpm --dir .agents/skills/infoq-browser-automation/scripts exec playwright install chromium'." >&2
  exit 1
fi

echo "[browser-flow] completed successfully"
