#!/usr/bin/env bash
# Assert temp-HOME helper wires pstack-models for Claude Code @-include loading.
# Optional first arg (plugin path) is ignored; run.sh always passes one.
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
# shellcheck disable=SC2034
_plugin_path="${1-}"
LIB="${ROOT}/scripts/lib/pstack-haiku-temp-home.sh"
FIXTURE="${ROOT}/.claude/skills/try-pstack-claude/assets/pstack-models.haiku-verification.mdc"

# shellcheck source=scripts/lib/pstack-haiku-temp-home.sh
source "${LIB}"
pstack_haiku_temp_home_prepare "${FIXTURE}"

claude_md="${PSTACK_TMP_CLAUDE}/CLAUDE.md"
models="${PSTACK_TMP_CLAUDE}/pstack-models.mdc"

if [[ ! -f ${models} ]]; then
	echo "ERROR: expected ${models}" >&2
	exit 1
fi
if [[ ! -f ${claude_md} ]]; then
	echo "ERROR: expected ${claude_md} for @-include" >&2
	exit 1
fi
if ! grep -Fq '@~/.claude/pstack-models.mdc' "${claude_md}"; then
	echo "ERROR: ${claude_md} must @-include pstack-models.mdc" >&2
	exit 1
fi
if ! grep -Fq 'feature, refactoring: haiku' "${models}"; then
	echo "ERROR: haiku fixture content missing in ${models}" >&2
	exit 1
fi

pstack_haiku_temp_home_cleanup
echo "pstack haiku temp HOME wiring OK."
