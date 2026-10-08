#!/usr/bin/env bash
# Static checks for pstack Claude slash skills and plugin agents (no API).
set -euo pipefail

PLUGIN_DIR="${1:-plugins/pstack}"

if [[ ! -d ${PLUGIN_DIR} ]]; then
	echo "ERROR: ${PLUGIN_DIR} not found" >&2
	exit 1
fi

read_frontmatter_name() {
	local skill_file="$1"
	awk 'BEGIN{n=0} /^---$/ {n++; next} n==1 && /^name:/ {sub(/^name:[[:space:]]*/,""); print; exit}' "${skill_file}"
}

check_skill_dir_name() {
	local dir_name="$1"
	local skill="${PLUGIN_DIR}/skills/${dir_name}/SKILL.md"
	if [[ ! -f ${skill} ]]; then
		echo "ERROR: Missing ${skill}" >&2
		return 1
	fi
	local fm_name
	fm_name="$(read_frontmatter_name "${skill}")"
	if [[ -z ${fm_name} ]]; then
		echo "ERROR: No frontmatter name in ${skill}" >&2
		return 1
	fi
	echo "  skill /${dir_name}: frontmatter name='${fm_name}'"
}

check_agent() {
	local file="$1"
	local expect_name="$2"
	local path="${PLUGIN_DIR}/agents/${file}"
	if [[ ! -f ${path} ]]; then
		echo "ERROR: Missing ${path}" >&2
		return 1
	fi
	local fm_name
	fm_name="$(read_frontmatter_name "${path}")"
	if [[ ${fm_name} != "${expect_name}" ]]; then
		echo "ERROR: ${path} name='${fm_name}' expected '${expect_name}'" >&2
		return 1
	fi
	echo "  agent ${expect_name}: OK"
}

echo "Validating pstack Claude components in ${PLUGIN_DIR}..."

for dir in setup-pstack poteto-help poteto-mode; do
	check_skill_dir_name "${dir}"
done

check_agent poteto-agent.md poteto-agent
check_agent comment-sicko.md "Comment Sicko"

if ! grep -q '^background: true' "${PLUGIN_DIR}/agents/poteto-agent.md"; then
	echo "ERROR: poteto-agent must set background: true" >&2
	exit 1
fi

echo "pstack Claude component validation passed."
