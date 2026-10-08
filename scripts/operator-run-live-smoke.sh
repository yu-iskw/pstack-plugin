#!/usr/bin/env bash
# Run comprehensive live workflow smoke from an operator terminal (not the Cursor agent shell).
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
cd "${ROOT}"

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq required." >&2
	exit 1
fi

auth_json="$(claude auth status 2>/dev/null || true)"
if ! jq -e '.loggedIn == true' <<<"${auth_json}" >/dev/null 2>&1; then
	echo "ERROR: claude auth status must show loggedIn: true." >&2
	echo "Run: claude login   (use your normal terminal, not the agent shell)" >&2
	exit 1
fi

api_provider="$(jq -r '.apiProvider // "unknown"' <<<"${auth_json}")"
if [[ ${api_provider} == vertex && -z ${PSTACK_VERIFY_MODEL-} ]]; then
	echo "NOTE: On Vertex, use a Model Garden haiku id (not the roster slug claude-haiku-5-5)." >&2
	echo "If unsure, run once: claude --print -p ok --model haiku" >&2
	echo "and copy the id from 'Try --model to switch to ...' in the error." >&2
	echo "Example for this deployment:" >&2
	echo "  export PSTACK_VERIFY_MODEL='claude-haiku-4-5@20251001'" >&2
	echo "See: .claude/skills/try-pstack-claude/references/vertex-and-external-auth.md" >&2
	echo "" >&2
fi

PROGRESS="${ROOT}/verification-evidence/live-in-progress.log"
if [[ ${PSTACK_LIVE_RESUME:-0} != 1 && -f ${PROGRESS} ]]; then
	if ! "${ROOT}/scripts/validate-pstack-live-log.sh" "${PROGRESS}" >/dev/null 2>&1; then
		echo "NOTE: incomplete ${PROGRESS} — to continue without re-running finished steps:" >&2
		echo "  export PSTACK_LIVE_RESUME=1" >&2
		echo "  cp verification-evidence/live-<partial>.log ${PROGRESS}" >&2
		echo "" >&2
	fi
fi

echo "==> Live workflow smoke (model=${PSTACK_VERIFY_MODEL:-haiku}; 9 API steps, often 10–20 min on Vertex)"
"${ROOT}/scripts/run-pstack-claude-verification.sh" --live-only --record

latest=""
for candidate in "${ROOT}"/verification-evidence/live-*.log; do
	[[ -f ${candidate} ]] || continue
	if [[ -z ${latest} || ${candidate} -nt ${latest} ]]; then
		latest="${candidate}"
	fi
done
if [[ -n ${latest} ]]; then
	cp "${latest}" "${ROOT}/verification-evidence/live-manual.log"
	echo "==> Updated verification-evidence/live-manual.log from ${latest}"
fi
