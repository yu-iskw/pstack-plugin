#!/usr/bin/env bash
# Operator entrypoint: static verify, optional --live API smoke, then interactive checklist.
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
VERIFY="${ROOT}/scripts/verify-pstack-claude-workspace.sh"
LIVE=false
LIVE_ONLY=false
RECORD=false

usage() {
	cat <<EOF
Usage: $(basename "$0") [--live] [--record]

  (default)  Static workspace verification.
  --live     Static checks plus haiku API smoke (requires claude auth loggedIn=true).
  --record   With --live, tee output to verification-evidence/live-<timestamp>.log

Then complete interactive steps in:
  .claude/skills/try-pstack-claude/references/interactive-smoke.md
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--live)
		LIVE=true
		shift
		;;
	--record)
		RECORD=true
		shift
		;;
	--live-only)
		LIVE=true
		LIVE_ONLY=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	esac
done

cd "${ROOT}"

VERIFY_ARGS=()
if [[ ${LIVE} == true ]]; then
	if [[ ${LIVE_ONLY} == true ]]; then
		VERIFY_ARGS=(--live-only)
	else
		VERIFY_ARGS=(--live)
	fi
fi

if [[ ${LIVE} == true && ${RECORD} == true ]]; then
	mkdir -p "${ROOT}/verification-evidence"
	LOG="${ROOT}/verification-evidence/live-$(date -u +%Y%m%dT%H%M%SZ).log"
	echo "Recording to ${LOG}"
	"${VERIFY}" "${VERIFY_ARGS[@]}" 2>&1 | tee "${LOG}"
	"${ROOT}/scripts/validate-pstack-live-log.sh" "${LOG}"
elif [[ ${#VERIFY_ARGS[@]} -gt 0 ]]; then
	"${VERIFY}" "${VERIFY_ARGS[@]}"
else
	"${VERIFY}"
fi

cat <<EOF

────────────────────────────────────────────────────────────
Interactive verification (paste results into the goal/PR thread)

Project \`AGENTS.md\` loads the haiku fixture; no ~/.claude/pstack-models.mdc required.

  cd ${ROOT}
  claude --setting-sources project,local,user --model haiku

With --live, workflow smoke also checks slash + Agent-tool tokens (see completion-audit.md).

Optional TUI checklist (interactive-smoke.md):
  /pstack:poteto-help, /pstack:poteto-mode, Agent tool spawns

Skip /pstack:setup-pstack when avoiding global ~/.claude edits.

Template: .claude/skills/try-pstack-claude/assets/verification-results.template.md
────────────────────────────────────────────────────────────
EOF
