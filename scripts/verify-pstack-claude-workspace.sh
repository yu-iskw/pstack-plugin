#!/usr/bin/env bash
# Workspace-only verification for pstack on Claude Code (claude CLI).
# Does not modify ~/.claude. --live uses real HOME (Vertex/trust) + project AGENTS.md haiku fixture.
set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
PLUGIN="${ROOT}/plugins/pstack"
SETTING_SOURCES=(--setting-sources 'project,local,user')
HAIKU_FIXTURE="${ROOT}/.claude/skills/try-pstack-claude/assets/pstack-models.haiku-verification.mdc"
LIVE=false
LIVE_ONLY=false

usage() {
	cat <<EOF
Usage: $(basename "$0") [--live] [--live-only]

Verifies the pstack Claude Code plugin from this repository without touching global
Claude config (except optional --live model file in a temporary HOME).

  --live        Static checks, then logged-in haiku API smoke (requires login).
  --live-only   API smoke only (skip static steps 1–8; run after make verify-pstack-claude).

Live mode requires claude login; loads haiku roles from project AGENTS.md (no ~/.claude/pstack-models.mdc write).

Resume a partial live log (skip steps whose tokens already appear in the progress file):
  PSTACK_LIVE_RESUME=1 PSTACK_LIVE_RESUME_LOG=verification-evidence/live-in-progress.log
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--live)
		LIVE=true
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

if ! command -v claude >/dev/null 2>&1; then
	echo "ERROR: claude CLI not found in PATH." >&2
	exit 1
fi

CLAUDE_TIMEOUT_SECS=120
CLAUDE_LIVE_TIMEOUT_SECS=360
claude_cmd() {
	if command -v timeout >/dev/null 2>&1; then
		timeout "${CLAUDE_TIMEOUT_SECS}" claude "$@"
	elif command -v gtimeout >/dev/null 2>&1; then
		gtimeout "${CLAUDE_TIMEOUT_SECS}" claude "$@"
	else
		claude "$@"
	fi
}

run_live_smoke() {
	local prev_timeout="${CLAUDE_TIMEOUT_SECS}"
	CLAUDE_TIMEOUT_SECS="${CLAUDE_LIVE_TIMEOUT_SECS}"

	if ! command -v jq >/dev/null 2>&1; then
		echo "ERROR: jq required for --live." >&2
		exit 1
	fi

	local logged_in=false
	local auth_json
	if auth_json="$(claude auth status 2>/dev/null)" && [[ -n ${auth_json} ]]; then
		if jq -e '.loggedIn == true' <<<"${auth_json}" >/dev/null 2>&1; then
			logged_in=true
		fi
	fi
	if [[ ${logged_in} != true ]]; then
		echo "ERROR: --live requires Claude login (claude auth status loggedIn=true)." >&2
		echo "Run: claude login" >&2
		exit 1
	fi

	cd "${ROOT}"
	local live_model="${PSTACK_VERIFY_MODEL:-haiku}"
	local live_budget_usd="${PSTACK_LIVE_MAX_BUDGET_USD:-1.00}"
	local resume_log="${PSTACK_LIVE_RESUME_LOG:-${ROOT}/verification-evidence/live-in-progress.log}"
	local resume_enabled=false
	if [[ ${PSTACK_LIVE_RESUME:-0} == 1 ]]; then
		resume_enabled=true
		if [[ -f ${resume_log} ]]; then
			echo "==> Resuming live smoke from ${resume_log}"
			cat "${resume_log}"
		else
			echo "WARN: PSTACK_LIVE_RESUME=1 but ${resume_log} missing; running all steps." >&2
			resume_enabled=false
		fi
	fi

	run_print_expect() {
		local prompt="$1"
		local expect_token="$2"
		shift 2
		if [[ ${resume_enabled} == true ]]; then
			if grep -Fq "STEP_OK: ${expect_token}" "${resume_log}" ||
				grep -Fxq "${expect_token}" "${resume_log}"; then
				echo "    RESUME_SKIP: ${expect_token} (already satisfied in ${resume_log})"
				return 0
			fi
		fi
		local extra=("$@")
		local tool_args=(--tools 'Read,Glob')
		local i=0
		while [[ ${i} -lt ${#extra[@]} ]]; do
			if [[ ${extra[${i}]} == --tools ]]; then
				tool_args=()
				break
			fi
			i=$((i + 1))
		done
		echo "    claude --print --model ${live_model} ${tool_args[*]} $*"
		echo "    prompt: ${prompt}"
		echo "    expect token: ${expect_token}"
		local output
		if ! output="$(
			claude "${SETTING_SOURCES[@]}" \
				--model "${live_model}" \
				--max-budget-usd "${live_budget_usd}" \
				--print \
				"${tool_args[@]}" \
				"${extra[@]}" \
				<<<"${prompt}" 2>&1
		)"; then
			echo "ERROR: claude --print failed." >&2
			echo "${output}" >&2
			return 1
		fi
		printf '%s\n' "${output}"
		if ! grep -Fq "${expect_token}" <<<"${output}"; then
			echo "ERROR: live smoke missing expected token: ${expect_token}" >&2
			return 1
		fi
		echo "    STEP_OK: ${expect_token}"
	}

	echo "==> Live smoke (model=${live_model}, project AGENTS.md fixture; real HOME for Vertex/trust)"
	echo '    If trust errors appear, run `claude` once in this repo and accept the workspace trust dialog.'
	run_print_expect 'Reply with exactly one line: PSTACK_LIVE=ok' 'PSTACK_LIVE=ok'
	run_print_expect 'Read plugins/pstack/skills/poteto-help/SKILL.md (first 20 lines). Reply with one line: POTETO_HELP_SKILL=ok' 'POTETO_HELP_SKILL=ok'
	run_print_expect 'Read plugins/pstack/skills/poteto-mode/SKILL.md (first 20 lines). Reply with one line: POTETO_MODE_SKILL=ok' 'POTETO_MODE_SKILL=ok'
	run_print_expect 'Reply with exactly one line: PSTACK_PLUGIN_AGENT=ok' 'PSTACK_PLUGIN_AGENT=ok' --agent 'pstack:poteto-agent'
	run_print_expect 'Reply with exactly one line: PSTACK_COMMENT_SICKO=ok' 'PSTACK_COMMENT_SICKO=ok' --agent 'pstack:Comment Sicko'

	echo "==> Workflow smoke (slash skills + Agent tool delegation via --print)"
	run_print_expect '/pstack:poteto-help Which playbook should I use for a small bug fix? End your reply with a line containing only SLASH_POTETO_HELP=ok' 'SLASH_POTETO_HELP=ok'
	run_print_expect '/pstack:poteto-mode Read-only: read Makefile (verify-pstack targets only) and summarize in one sentence. End with a line containing only SLASH_POTETO_MODE=ok' 'SLASH_POTETO_MODE=ok' --tools Read,Glob
	run_print_expect 'Use the Agent tool exactly once to delegate to subagent pstack:poteto-agent with the message: Reply with exactly one line PSTACK_AGENT_TOOL=ok. Include that line in your final reply.' 'PSTACK_AGENT_TOOL=ok' --tools default --permission-mode bypassPermissions --max-budget-usd 2.00
	run_print_expect 'Use the Agent tool exactly once to delegate to subagent pstack:Comment Sicko with the message: Reply with exactly one line PSTACK_COMMENT_SICKO_TOOL=ok. Include that line in your final reply.' 'PSTACK_COMMENT_SICKO_TOOL=ok' --tools default --permission-mode bypassPermissions --max-budget-usd 2.00

	echo ""
	echo "OK: Static + live haiku smoke passed (including slash + Agent-tool workflow tokens)."
	echo "Optional: run interactive-smoke.md TUI once if you want a manual UI pass."

	CLAUDE_TIMEOUT_SECS="${prev_timeout}"
}

echo "==> Repo root: ${ROOT}"
echo "==> Plugin: ${PLUGIN}"
cd "${ROOT}"

if [[ ${LIVE_ONLY} == true ]]; then
	if [[ ! -f ${HAIKU_FIXTURE} ]]; then
		echo "ERROR: Missing ${HAIKU_FIXTURE}" >&2
		exit 1
	fi
	run_live_smoke
	exit 0
fi

echo "==> [1/8] Integration manifest + component discovery"
./integration_tests/run.sh --skip-loading

echo "==> [2/8] claude plugin validate"
claude_cmd plugin validate "${PLUGIN}"
echo "    [2/8] OK"

echo "==> [3/8] Ephemeral load via --plugin-dir= (no marketplace install required)"
if ! claude_cmd --plugin-dir="${PLUGIN}" plugin list 2>&1 | grep -Fq 'pstack'; then
	echo "ERROR: pstack not visible in 'claude --plugin-dir=${PLUGIN} plugin list'." >&2
	claude_cmd --plugin-dir="${PLUGIN}" plugin list >&2 || true
	exit 1
fi
echo "    [3/8] OK"

echo "==> [4/8] Plugin agents registered (local scope install or enabledPlugins)"
AGENTS_OUT="$(claude_cmd "${SETTING_SOURCES[@]}" agents 2>&1)" || {
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
echo "    [4/8] OK"

echo "==> [5/8] Skill inventory (portable discovery)"
SKILL_COUNT="$(find "${PLUGIN}/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
echo "    ${SKILL_COUNT} skills under plugins/pstack/skills/"

echo "==> [6/8] Core workflow skills and subagent definitions"
CORE_SKILLS=(setup-pstack poteto-help poteto-mode swarm arena how why reflect interrogate)
for name in "${CORE_SKILLS[@]}"; do
	if [[ ! -f ${PLUGIN}/skills/${name}/SKILL.md ]]; then
		echo "ERROR: Missing core skill: plugins/pstack/skills/${name}/SKILL.md" >&2
		exit 1
	fi
done
for agent in poteto-agent.md comment-sicko.md; do
	if [[ ! -f ${PLUGIN}/agents/${agent} ]]; then
		echo "ERROR: Missing agent: plugins/pstack/agents/${agent}" >&2
		exit 1
	fi
done
echo "    Core skills and agents present."

echo "==> [7/8] Slash skill and agent frontmatter"
"${ROOT}/integration_tests/validate-pstack-claude-components.sh" "${PLUGIN}"

echo "==> [8/8] Haiku smoke fixture (try-pstack-claude skill, not in plugin)"
if [[ ! -f ${HAIKU_FIXTURE} ]]; then
	echo "ERROR: Missing ${HAIKU_FIXTURE}" >&2
	exit 1
fi
if grep -q '^opus' "${HAIKU_FIXTURE}" || grep -E ': opus' "${HAIKU_FIXTURE}" | grep -qv '^#'; then
	echo "ERROR: Haiku fixture must not assign opus roles." >&2
	exit 1
fi
PROJECT_AGENTS="${ROOT}/AGENTS.md"
if [[ ! -f ${PROJECT_AGENTS} ]] ||
	! grep -Fq '@.claude/skills/try-pstack-claude/assets/pstack-models.haiku-verification.mdc' "${PROJECT_AGENTS}"; then
	echo "ERROR: ${PROJECT_AGENTS} must @-include the haiku verification fixture (project-local models)." >&2
	exit 1
fi
echo "    Haiku-only fixture OK; project AGENTS.md @-include OK."

PROJECT_SETTINGS="${ROOT}/.claude/settings.json"
if [[ ! -f ${PROJECT_SETTINGS} ]] ||
	! grep -Fq '"pstack@pstack-plugin": true' "${PROJECT_SETTINGS}"; then
	echo "ERROR: ${PROJECT_SETTINGS} must enable pstack@pstack-plugin in enabledPlugins." >&2
	exit 1
fi
echo "    Project settings enable pstack@pstack-plugin."

if [[ ${LIVE} != true ]]; then
	echo ""
	echo "OK: Static Claude Code workspace verification passed."
	echo "Remaining (requires claude login): live workflow smoke (slash + Agent-tool tokens)."
	echo "  $(basename "$0") --live-only --record"
	echo "  Optional TUI: .claude/skills/try-pstack-claude/references/interactive-smoke.md"
	exit 0
fi

run_live_smoke
