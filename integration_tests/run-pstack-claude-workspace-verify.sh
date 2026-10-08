#!/usr/bin/env bash
# Run scripts/verify-pstack-claude-workspace.sh (static). Optional plugin arg ignored.
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
VERIFY="${ROOT}/scripts/verify-pstack-claude-workspace.sh"

if [[ ! -x ${VERIFY} ]]; then
	echo "SKIP: ${VERIFY} not found (partial checkout?)"
	exit 0
fi

exec "${VERIFY}"
