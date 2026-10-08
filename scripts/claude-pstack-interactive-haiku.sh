#!/usr/bin/env bash
# Interactive Claude Code session: haiku parent + temp pstack-models (all roles haiku).
# Does not write or read your real ~/.claude/pstack-models.mdc for model config.
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
LIB="${ROOT}/scripts/lib/pstack-haiku-temp-home.sh"
HAIKU_FIXTURE="${ROOT}/.claude/skills/try-pstack-claude/assets/pstack-models.haiku-verification.mdc"
SETTING_SOURCES=(--setting-sources 'project,local,user')

usage() {
	cat <<EOF
Usage: $(basename "$0") [claude options...]

Starts \`claude --model haiku\` from the repository root with a temporary HOME that
contains only the try-pstack-claude haiku verification fixture as pstack-models.mdc.
OAuth and installed plugins are symlinked from your real ~/.claude.

Run interactive smoke from .claude/skills/try-pstack-claude/references/interactive-smoke.md
Skip /pstack:setup-pstack — it targets ~/.claude/pstack-models.mdc.

Requires \`claude auth status\` loggedIn=true for API calls.
EOF
}

if [[ ${1-} == -h || ${1-} == --help ]]; then
	usage
	exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
	echo "ERROR: claude CLI not found in PATH." >&2
	exit 1
fi

# shellcheck source=scripts/lib/pstack-haiku-temp-home.sh
source "${LIB}"
pstack_haiku_temp_home_prepare "${HAIKU_FIXTURE}"

cd "${ROOT}"
echo "==> Repo: ${ROOT}"
echo "==> Temp HOME (pstack-models only): ${PSTACK_TMP_HOME}"
echo "==> Real ~/.claude/pstack-models.mdc is unchanged."
echo "==> Starting: claude ${SETTING_SOURCES[*]} --model haiku $*"
echo ""

set +e
HOME="${PSTACK_TMP_HOME}" claude "${SETTING_SOURCES[@]}" --model haiku "$@"
status=$?
set -e
pstack_haiku_temp_home_cleanup
exit "${status}"
