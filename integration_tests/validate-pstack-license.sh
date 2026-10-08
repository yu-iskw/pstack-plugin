#!/usr/bin/env bash
# Ensure vendored pstack keeps upstream MIT license metadata and LICENSE file.
set -euo pipefail

plugin_dir="${1:-plugins/pstack}"
manifest="${plugin_dir}/plugin.json"
license_file="${plugin_dir}/LICENSE"

if [[ ! -f ${manifest} ]]; then
	echo "ERROR: Missing ${manifest}" >&2
	exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: jq is required." >&2
	exit 1
fi

license="$(jq -r '.license // empty' "${manifest}")"
repo="$(jq -r '.repository // empty' "${manifest}")"

if [[ ${license} != MIT ]]; then
	echo "ERROR: ${manifest} license must be MIT (upstream pstack); got: ${license:-<empty>}" >&2
	exit 1
fi

if [[ ${repo} != https://github.com/cursor/plugins ]]; then
	echo "ERROR: ${manifest} repository must be https://github.com/cursor/plugins; got: ${repo:-<empty>}" >&2
	exit 1
fi

if [[ ! -f ${license_file} ]]; then
	echo "ERROR: Missing ${license_file}" >&2
	exit 1
fi

if ! head -n 1 "${license_file}" | grep -Fq 'MIT License'; then
	echo "ERROR: ${license_file} must be upstream MIT text (first line: MIT License)." >&2
	exit 1
fi

repo_root="$(CDPATH='' cd -- "$(dirname -- "${plugin_dir}")/.." && pwd)"
root_license="${repo_root}/LICENSE"
if [[ ! -f ${root_license} ]]; then
	echo "ERROR: Missing repository root LICENSE: ${root_license}" >&2
	exit 1
fi
if ! head -n 1 "${root_license}" | grep -Fq 'MIT License'; then
	echo "ERROR: ${root_license} must be MIT (first line: MIT License)." >&2
	exit 1
fi
if ! cmp -s "${license_file}" "${root_license}"; then
	echo "ERROR: ${root_license} must match ${license_file} (upstream MIT)." >&2
	exit 1
fi

echo "pstack license validation passed (MIT, cursor/plugins)."
