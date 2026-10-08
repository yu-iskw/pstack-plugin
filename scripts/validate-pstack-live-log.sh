#!/usr/bin/env bash
# Validate a recorded --live-only log against completion-audit.md tokens.
set -euo pipefail

usage() {
	cat <<EOF
Usage: $(basename "$0") <path-to-live.log>

Checks required live workflow tokens and the success footer from
scripts/verify-pstack-claude-workspace.sh --live-only.
EOF
}

if [[ $# -lt 1 ]]; then
	usage >&2
	exit 1
fi

LOG="$1"
if [[ ! -f ${LOG} ]]; then
	echo "ERROR: not a file: ${LOG}" >&2
	exit 1
fi

REQUIRED=(
	PSTACK_LIVE=ok
	POTETO_HELP_SKILL=ok
	POTETO_MODE_SKILL=ok
	PSTACK_PLUGIN_AGENT=ok
	PSTACK_COMMENT_SICKO=ok
	SLASH_POTETO_HELP=ok
	SLASH_POTETO_MODE=ok
	PSTACK_AGENT_TOOL=ok
	PSTACK_COMMENT_SICKO_TOOL=ok
)

missing=0
for token in "${REQUIRED[@]}"; do
	if ! grep -Fq "${token}" "${LOG}"; then
		echo "MISSING token: ${token}" >&2
		missing=1
	fi
done

if ! grep -Fq 'OK: Static + live haiku smoke passed (including slash + Agent-tool workflow tokens).' "${LOG}"; then
	echo "MISSING success footer (re-run with current verify script)." >&2
	missing=1
fi

# Vertex prints a Model Garden banner (Opus tier unavailable) even when --model is haiku; ignore it.
pstack_haiku_policy_violation() {
	local log="$1"
	local line
	while IFS= read -r line; do
		if [[ ${line} =~ (using[[:space:]]Sonnet|using[[:space:]]Opus) ]]; then
			if [[ ${line} =~ ^Warning:[[:space:]]Opus:.*not[[:space:]]available ]]; then
				continue
			fi
			return 0
		fi
	done <"${log}"
	return 1
}

policy_fail=0
set +e
pstack_haiku_policy_violation "${LOG}"
policy_violation_rc=$?
set -e
haiku_policy_broken=false
if [[ ${policy_violation_rc} -eq 0 ]]; then
	haiku_policy_broken=true
fi
if [[ ${haiku_policy_broken} == true ]]; then
	if [[ ${PSTACK_ALLOW_NON_HAIKU_LOG:-0} == 1 ]]; then
		echo "WARN: log shows Sonnet/Opus fallback; PSTACK_ALLOW_NON_HAIKU_LOG=1 (not valid for haiku-only comprehensive verify)." >&2
	else
		echo "FAIL: log shows Sonnet/Opus model fallback (excluding Vertex Opus tier banner)." >&2
		echo "  Re-run with PSTACK_VERIFY_MODEL set to your Vertex haiku id." >&2
		echo "  See .claude/skills/try-pstack-claude/references/vertex-and-external-auth.md" >&2
		policy_fail=1
	fi
fi

if [[ ${missing} -ne 0 ]]; then
	echo "FAIL: ${LOG} does not satisfy live workflow smoke." >&2
	exit 1
fi

if [[ ${policy_fail} -ne 0 ]]; then
	exit 1
fi

echo "OK: ${LOG} contains all ${#REQUIRED[@]} live workflow tokens (haiku-only policy)."
