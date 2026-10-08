#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OP="${ROOT}/scripts/operator-run-live-smoke.sh"

if [[ ! -x ${OP} ]]; then
	echo "ERROR: missing or not executable: ${OP}" >&2
	exit 1
fi

bash -n "${OP}"

for needle in PSTACK_VERIFY_MODEL run-pstack-claude-verification live-manual.log; do
	if ! grep -Fq "${needle}" "${OP}"; then
		echo "ERROR: ${OP} missing expected reference: ${needle}" >&2
		exit 1
	fi
done

echo "operator-run-live-smoke.sh wiring OK."
