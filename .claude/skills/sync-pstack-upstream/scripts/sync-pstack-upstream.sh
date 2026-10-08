#!/usr/bin/env bash
# Copyright 2026 yu-iskw
#
# Sync plugins/pstack from cursor/plugins (pstack/) and apply Claude overlay patches.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if ! REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null)"; then
	REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
fi
PLUGIN_DIR="${REPO_ROOT}/plugins/pstack"
PATCH_DIR="${REPO_ROOT}/patches/pstack"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/cursor/plugins.git}"
UPSTREAM_REF="${UPSTREAM_REF:-main}"
UPSTREAM_PATH="pstack"
SKIP_PATCHES="${SKIP_PATCHES:-false}"
CHECK_ONLY="${CHECK_ONLY:-false}"

usage() {
	cat <<'EOF'
Usage: sync-pstack-upstream.sh [--check]

  UPSTREAM_REPO   Git remote (default: https://github.com/cursor/plugins.git)
  UPSTREAM_REF    Branch or tag (default: main)
  SKIP_PATCHES    If true, skip applying patches/pstack/*.patch
  CHECK_ONLY      Exit 1 if sync would change the working tree (for CI)

Environment variables override defaults. Pass --check to set CHECK_ONLY=true.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--check)
		CHECK_ONLY=true
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

if ! command -v rsync >/dev/null 2>&1; then
	echo "ERROR: rsync is required." >&2
	exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq is required." >&2
	exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "Cloning ${UPSTREAM_REPO} (${UPSTREAM_REF})..."
git clone --depth 1 --branch "${UPSTREAM_REF}" "${UPSTREAM_REPO}" "${tmpdir}/upstream" 2>/dev/null || {
	git clone --depth 1 "${UPSTREAM_REPO}" "${tmpdir}/upstream"
	git -C "${tmpdir}/upstream" checkout "${UPSTREAM_REF}"
}

upstream_commit="$(git -C "${tmpdir}/upstream" rev-parse HEAD)"
upstream_src="${tmpdir}/upstream/${UPSTREAM_PATH}"

if [[ ! -d ${upstream_src} ]]; then
	echo "ERROR: upstream path not found: ${UPSTREAM_PATH}" >&2
	exit 1
fi

mkdir -p "${PLUGIN_DIR}"

owned_stash="${tmpdir}/owned-stash"
mkdir -p "${owned_stash}"
for rel in plugin.json UPSTREAM.json README.claude-header.md README.md docs/claude-smoke-checklist.md; do
	if [[ -f ${PLUGIN_DIR}/${rel} ]]; then
		mkdir -p "${owned_stash}/$(dirname "${rel}")"
		cp "${PLUGIN_DIR}/${rel}" "${owned_stash}/${rel}"
	fi
done
if [[ -d ${PLUGIN_DIR}/.claude-plugin ]]; then
	cp -R "${PLUGIN_DIR}/.claude-plugin" "${owned_stash}/.claude-plugin"
fi

echo "Rsyncing ${UPSTREAM_PATH}/ -> ${PLUGIN_DIR}/ ..."
rsync -a --delete \
	--exclude '.cursor-plugin/' \
	--exclude 'plugin.json' \
	--exclude '.claude-plugin/' \
	--exclude 'UPSTREAM.json' \
	--exclude 'README.claude-header.md' \
	--exclude 'README.md' \
	--exclude 'docs/claude-smoke-checklist.md' \
	"${upstream_src}/" "${PLUGIN_DIR}/"

for rel in plugin.json UPSTREAM.json README.claude-header.md README.md docs/claude-smoke-checklist.md; do
	if [[ -f ${owned_stash}/${rel} ]]; then
		mkdir -p "${PLUGIN_DIR}/$(dirname "${rel}")"
		cp "${owned_stash}/${rel}" "${PLUGIN_DIR}/${rel}"
	fi
done
if [[ -d ${owned_stash}/.claude-plugin ]]; then
	rm -rf "${PLUGIN_DIR}/.claude-plugin"
	cp -R "${owned_stash}/.claude-plugin" "${PLUGIN_DIR}/.claude-plugin"
fi

upstream_version=""
if [[ -f ${upstream_src}/.cursor-plugin/plugin.json ]]; then
	upstream_version="$(jq -r '.version // empty' "${upstream_src}/.cursor-plugin/plugin.json")"
fi

synced_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
jq -n \
	--arg repo "${UPSTREAM_REPO}" \
	--arg path "${UPSTREAM_PATH}" \
	--arg ref "${UPSTREAM_REF}" \
	--arg commit "${upstream_commit}" \
	--arg version "${upstream_version}" \
	--arg syncedAt "${synced_at}" \
	'{repo: $repo, path: $path, ref: $ref, commit: $commit, version: $version, syncedAt: $syncedAt}' \
	> "${PLUGIN_DIR}/UPSTREAM.json"

if [[ ${SKIP_PATCHES} != true ]]; then
	if [[ -d ${PATCH_DIR} ]]; then
		shopt -s nullglob
		patches=("${PATCH_DIR}"/*.patch)
		shopt -u nullglob
		if [[ ${#patches[@]} -gt 0 ]]; then
			echo "Applying ${#patches[@]} patch(es) from ${PATCH_DIR}..."
			for patch in "${patches[@]}"; do
				echo "  -> $(basename "${patch}")"
				if ! git -C "${REPO_ROOT}" apply -p0 "${patch}"; then
					echo "ERROR: failed to apply ${patch}" >&2
					echo "Refresh patches after upstream changes (see patches/pstack/README.md)." >&2
					exit 1
				fi
			done
		fi
	fi
fi

if [[ -f ${PLUGIN_DIR}/README.claude-header.md ]]; then
	{
		cat "${PLUGIN_DIR}/README.claude-header.md"
		echo ""
		cat "${upstream_src}/README.md"
	} > "${PLUGIN_DIR}/README.md"
elif [[ -f ${upstream_src}/README.md ]]; then
	cp "${upstream_src}/README.md" "${PLUGIN_DIR}/README.md"
fi

skill_count="$(find "${PLUGIN_DIR}/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
agent_count="$(find "${PLUGIN_DIR}/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"

echo "Upstream commit: ${upstream_commit}"
echo "Upstream version: ${upstream_version:-unknown}"
echo "Skills: ${skill_count}, agents: ${agent_count}"
echo "Wrote ${PLUGIN_DIR}/UPSTREAM.json"

if [[ -n ${upstream_version} ]]; then
	echo "If version changed, update plugins/pstack/plugin.json, .claude-plugin/plugin.json, and .claude-plugin/marketplace.json."
fi

if [[ ${CHECK_ONLY} == true ]]; then
	if ! git -C "${REPO_ROOT}" diff --quiet -- plugins/pstack patches/pstack; then
		echo "CHECK: plugins/pstack differs from last commit after sync." >&2
		git -C "${REPO_ROOT}" status --short plugins/pstack >&2 || true
		exit 1
	fi
	echo "CHECK: plugins/pstack matches synced upstream + patches."
fi
