#!/usr/bin/env bash
# Render plugins/pstack/claude/pstack-role-defaults*.txt from model-roster.json profiles

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROSTER="${SKILL_DIR}/references/model-roster.json"
OUT_DIR="$(git -C "${SKILL_DIR}" rev-parse --show-toplevel 2>/dev/null)/plugins/pstack/claude"

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq is required." >&2
	exit 1
fi

mkdir -p "${OUT_DIR}"

pricing_as_of="$(jq -r '.pricingAsOf' "${ROSTER}")"
pricing_source="$(jq -r '.pricingSource' "${ROSTER}")"

render_profile() {
	local profile_key="$1"
	local out_name
	out_name="$(jq -r --arg k "${profile_key}" '.profiles[$k].outputFile' "${ROSTER}")"
	local profile_label
	profile_label="$(jq -r --arg k "${profile_key}" '.profiles[$k].profile' "${ROSTER}")"
	local header_budget
	header_budget="$(jq -r --arg k "${profile_key}" '.profiles[$k].headerBudget' "${ROSTER}")"
	local out_file="${OUT_DIR}/${out_name}"

	{
		echo "# pstack role defaults (Claude Code). Generated from tune-pstack-models."
		echo "# pricingAsOf: ${pricing_as_of} — ${pricing_source}"
		echo "# profile: ${profile_label}"
		echo "# budget: ${header_budget}"
		echo "# Role lines use Claude Code aliases opus, sonnet, haiku (https://code.claude.com/docs/en/model-config)."
		jq -r --arg k "${profile_key}" \
			'.profiles[$k].roleDefaults | to_entries[] | if (.value | type) == "array" then "\(.key): \(.value | join(", "))" else "\(.key): \(.value)" end' \
			"${ROSTER}"
	} >"${out_file}"

	echo "Wrote ${out_file}"
}

while IFS= read -r profile_key; do
	render_profile "${profile_key}"
done < <(jq -r '.profiles | keys[]' "${ROSTER}")
