#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VALIDATE="${ROOT}/scripts/validate-pstack-live-log.sh"
FIXTURE="${SCRIPT_DIR}/fixtures/pstack-live-log-vertex-banner-snippet.log"

if ! "${VALIDATE}" "${FIXTURE}" >/dev/null; then
	echo "ERROR: vertex banner fixture should pass haiku policy + tokens" >&2
	exit 1
fi

echo "validate-pstack-live-log vertex banner policy OK."
