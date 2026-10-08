#!/usr/bin/env bash
# Ensures live workflow smoke in verify-pstack-claude-workspace.sh stays aligned with completion-audit.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERIFY="${ROOT}/scripts/verify-pstack-claude-workspace.sh"

if [[ ! -f ${VERIFY} ]]; then
	echo "ERROR: missing ${VERIFY}" >&2
	exit 1
fi

REQUIRED_TOKENS=(
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
for token in "${REQUIRED_TOKENS[@]}"; do
	if ! grep -Fq "'${token}'" "${VERIFY}" && ! grep -Fq "\"${token}\"" "${VERIFY}"; then
		echo "ERROR: ${VERIFY} missing live expect token: ${token}" >&2
		missing=1
	fi
done

if ! grep -Fq 'Workflow smoke (slash skills + Agent tool delegation' "${VERIFY}"; then
	echo "ERROR: ${VERIFY} missing workflow smoke section" >&2
	missing=1
fi

if ! grep -Fq "PSTACK_AGENT_TOOL=ok' --tools default" "${VERIFY}"; then
	echo "ERROR: ${VERIFY} Agent-tool smoke must pass --tools default" >&2
	missing=1
fi

if ! grep -Fq 'PSTACK_VERIFY_MODEL' "${VERIFY}"; then
	echo "ERROR: ${VERIFY} must support PSTACK_VERIFY_MODEL for Vertex haiku ids" >&2
	missing=1
fi

if [[ ${missing} -ne 0 ]]; then
	exit 1
fi

echo "pstack Claude live smoke contract OK (${#REQUIRED_TOKENS[@]} tokens)."
