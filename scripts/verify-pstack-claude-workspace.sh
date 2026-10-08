#!/usr/bin/env bash
# Workspace-only verification for pstack on Claude Code (claude CLI).
# Does not modify ~/.claude unless you pass --live (uses a temp HOME for pstack-models only).
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
PLUGIN="${ROOT}/plugins/pstack"
MARKETPLACE_JSON="${ROOT}/.claude-plugin/marketplace.json"
SETTING_SOURCES=(--setting-sources project,local,user)
LIVE=false

usage() {
	cat <<EOF
Usage: $(basename "$0") [--live]

Verifies the pstack Claude Code plugin from this repository without touching global
Claude config (except optional --live model file in a temporary HOME).

  --live   Run logged-in smoke prompts with --model haiku and haiku-only role defaults
           (requires \`claude auth status\` loggedIn=true). Uses temp HOME for
           ~/.claude/pstack-models.mdc only; OAuth stays in your real home.

Static checks always run: integration manifest, claude plugin validate, agents, plugin-dir load.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--live)
		LIVE=true
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

if ! command -v claude >/dev/null 2>&1; then
	echo "ERROR: claude CLI not found in PATH." >&2
	exit 1
fi

echo "==> Repo root: ${ROOT}"
echo "==> Plugin: ${PLUGIN}"
cd "${ROOT}"

echo "==> [1/5] Integration manifest + component discovery"
./integration_tests/run.sh --skip-loading

echo "==> [2/5] claude plugin validate"
claude plugin validate "${PLUGIN}"

echo "==> [3/5] Ephemeral load via --plugin-dir= (no marketplace install required)"
if ! claude --plugin-dir="${PLUGIN}" plugin list 2>&1 | grep -Fq 'pstack'; then
	echo "ERROR: pstack not visible in 'claude --plugin-dir=${PLUGIN} plugin list'." >&2
	claude --plugin-dir="${PLUGIN}" plugin list >&2 || true
	exit 1
fi

echo "==> [4/5] Plugin agents registered (local scope install or enabledPlugins)"
AGENTS_OUT="$(claude "${SETTING_SOURCES[@]}" agents 2>&1)" || {
	echo "ERROR: claude agents failed." >&2
	echo "${AGENTS_OUT}" >&2
	exit 1
}
if ! grep -Fq 'pstack:poteto-agent' <<<"${AGENTS_OUT}"; then
	echo "ERROR: pstack:poteto-agent not listed. Install once from this repo:" >&2
	echo "  cd ${ROOT}" >&2
	echo "  claude plugin marketplace add \"${ROOT}\"" >&2
	echo "  claude --setting-sources project,local plugin install -s local pstack@pstack-plugin" >&2
	echo "${AGENTS_OUT}" >&2
	exit 1
fi
if ! grep -Fq 'pstack:Comment Sicko' <<<"${AGENTS_OUT}"; then
	echo "ERROR: pstack:Comment Sicko not listed." >&2
	echo "${AGENTS_OUT}" >&2
	exit 1
fi
echo "    Found pstack plugin agents."

echo "==> [5/5] Skill inventory (portable discovery)"
SKILL_COUNT="$(find "${PLUGIN}/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
echo "    ${SKILL_COUNT} skills under plugins/pstack/skills/"

if [[ ${LIVE} != true ]]; then
	echo ""
	echo "OK: Static Claude Code workspace verification passed."
	echo "For interactive slash commands (/setup-pstack, /poteto-help, /poteto-mode), run:"
	echo "  cd ${ROOT} && claude ${SETTING_SOURCES[*]}"
	echo "Optional API smoke (haiku, temp pstack-models only):"
	echo "  $(basename "$0") --live"
	exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq required for --live." >&2
	exit 1
fi

LOGGED_IN=false
if auth_json="$(claude auth status 2>/dev/null)" && [[ -n ${auth_json} ]]; then
	if jq -e '.loggedIn == true' <<<"${auth_json}" >/dev/null 2>&1; then
		LOGGED_IN=true
	fi
fi
if [[ ${LOGGED_IN} != true ]]; then
	echo "ERROR: --live requires Claude login (claude auth status loggedIn=true)." >&2
	exit 1
fi

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "${TMP_HOME}"' EXIT
mkdir -p "${TMP_HOME}/.claude"
cp "${PLUGIN}/claude/pstack-role-defaults.haiku-verification.txt" "${TMP_HOME}/.claude/pstack-models.mdc"

run_print() {
	local prompt="$1"
	echo "    prompt: ${prompt}"
	HOME="${TMP_HOME}" claude "${SETTING_SOURCES[@]}" \
		--model haiku \
		--max-budget-usd 0.35 \
		--print \
		--tools Read,Glob \
		<<<"${prompt}"
}

echo "==> Live smoke (haiku, temp pstack-models in ${TMP_HOME})"
run_print 'Reply with exactly one line: PSTACK_LIVE=ok'
run_print 'Read plugins/pstack/skills/poteto-help/SKILL.md (first 20 lines). Reply with one line: POTETO_HELP_SKILL=ok'

echo ""
echo "OK: Static + live haiku smoke passed. Run an interactive session for /poteto-mode and subagent spawns."
