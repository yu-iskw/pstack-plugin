#!/usr/bin/env bash
# live-manual.log is operator-maintained evidence; must not claim comprehensive pass without workflow tokens.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG="${ROOT}/verification-evidence/live-manual.log"
VALIDATE="${ROOT}/scripts/validate-pstack-live-log.sh"

if [[ ! -f ${LOG} ]]; then
	echo "SKIP: no ${LOG} (operator has not recorded live smoke yet)."
	exit 0
fi

if "${VALIDATE}" "${LOG}"; then
	echo "live-manual.log satisfies comprehensive live workflow contract."
	exit 0
fi

echo "NOTE: live-manual.log is stale (missing slash/Agent-tool tokens). Re-run:" >&2
echo "  ./scripts/run-pstack-claude-verification.sh --live-only --record" >&2
exit 0
