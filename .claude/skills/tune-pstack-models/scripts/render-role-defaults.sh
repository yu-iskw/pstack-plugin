#!/usr/bin/env bash
# Render plugins/pstack/claude/pstack-role-defaults.txt from model-roster.json

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROSTER="${SKILL_DIR}/references/model-roster.json"
OUT_DIR="$(git -C "${SKILL_DIR}" rev-parse --show-toplevel 2>/dev/null)/plugins/pstack/claude"
OUT_FILE="${OUT_DIR}/pstack-role-defaults.txt"

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq is required." >&2
	exit 1
fi

mkdir -p "${OUT_DIR}"

pricing_as_of="$(jq -r '.pricingAsOf' "${ROSTER}")"
pricing_source="$(jq -r '.pricingSource' "${ROSTER}")"

{
	echo "# pstack role defaults (Claude Code). Generated from tune-pstack-models."
	echo "# pricingAsOf: ${pricing_as_of} — ${pricing_source}"
	echo "# budget: large (high)"
	jq -r '.roleDefaults | to_entries[] | if (.value | type) == "array" then "\(.key): \(.value | join(", "))" else "\(.key): \(.value)" end' "${ROSTER}"
} >"${OUT_FILE}"

echo "Wrote ${OUT_FILE}"
