#!/usr/bin/env sh
set -eu

print_help() {
  cat <<'EOF'
Usage:
  sh .agents/skills/infoq-browser-automation/scripts/run_admin_route_probe.sh [options]

Options:
  --frontend-origin <origin>
  --route <route>
  --backend-url <url>
  --client-id <id>
  --username <value>
  --password <value>
  --wait-for-text <text>
  --screenshot-path <path>
  --console-log-path <path>
  --timeout-ms <ms>
  --list-routes
  --headed
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

FRONTEND_ORIGIN=""
ROUTE="/index"
BACKEND_URL="http://127.0.0.1:8080"
CLIENT_ID="e5cd7e4891bf95d1d19206ce24a7b32e"
USERNAME=""
PASSWORD=""
WAIT_FOR_TEXT=""
SCREENSHOT_PATH=""
CONSOLE_LOG_PATH=""
TIMEOUT_MS="45000"
LIST_ROUTES=0
HEADED=0
ALLOW_CONSOLE_ERRORS=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --frontend-origin)
      require_value "$1" "${2-}"
      FRONTEND_ORIGIN=$2
      shift 2
      ;;
    --route)
      require_value "$1" "${2-}"
      ROUTE=$2
      shift 2
      ;;
    --backend-url)
      require_value "$1" "${2-}"
      BACKEND_URL=$2
      shift 2
      ;;
    --client-id)
      require_value "$1" "${2-}"
      CLIENT_ID=$2
      shift 2
      ;;
    --username)
      require_value "$1" "${2-}"
      USERNAME=$2
      shift 2
      ;;
    --password)
      require_value "$1" "${2-}"
      PASSWORD=$2
      shift 2
      ;;
    --wait-for-text)
      require_value "$1" "${2-}"
      WAIT_FOR_TEXT=$2
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
    --list-routes)
      LIST_ROUTES=1
      shift
      ;;
    --headed)
      HEADED=1
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

if [ "$LIST_ROUTES" -ne 1 ] && [ -z "$FRONTEND_ORIGIN" ]; then
  echo "--frontend-origin is required unless --list-routes is used." >&2
  print_help >&2
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required but was not found in PATH." >&2
  exit 1
fi

set -- run playwright-cli admin-route-probe \
  --backend-url "$BACKEND_URL" \
  --client-id "$CLIENT_ID" \
  --route "$ROUTE" \
  --timeout-ms "$TIMEOUT_MS"

if [ -n "$FRONTEND_ORIGIN" ]; then
  set -- "$@" --frontend-origin "$FRONTEND_ORIGIN"
fi
if [ -n "$USERNAME" ]; then
  set -- "$@" --username "$USERNAME"
fi
if [ -n "$PASSWORD" ]; then
  set -- "$@" --password "$PASSWORD"
fi
if [ -n "$WAIT_FOR_TEXT" ]; then
  set -- "$@" --wait-for-text "$WAIT_FOR_TEXT"
fi
if [ -n "$SCREENSHOT_PATH" ]; then
  set -- "$@" --screenshot-path "$SCREENSHOT_PATH"
fi
if [ -n "$CONSOLE_LOG_PATH" ]; then
  set -- "$@" --console-log-path "$CONSOLE_LOG_PATH"
fi
if [ "$LIST_ROUTES" -eq 1 ]; then
  set -- "$@" --list-routes
fi
if [ "$HEADED" -eq 1 ]; then
  set -- "$@" --headed
fi
if [ "$ALLOW_CONSOLE_ERRORS" -eq 1 ]; then
  set -- "$@" --allow-console-errors
fi

if ! (
  cd "$SCRIPT_DIR"
  pnpm "$@"
); then
  echo "Admin route probe failed." >&2
  exit 1
fi
