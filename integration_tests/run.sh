#!/usr/bin/env bash

# Copyright 2026 yu-iskw
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

SKIP_LOADING=false
MANIFEST_ONLY=false
VERBOSE=false
FAIL_FAST=false

while [[ $# -gt 0 ]]; do
	case "$1" in
	--skip-loading)
		SKIP_LOADING=true
		shift
		;;
	--manifest-only)
		MANIFEST_ONLY=true
		shift
		;;
	--verbose | -v)
		VERBOSE=true
		shift
		;;
	--fail-fast)
		FAIL_FAST=true
		shift
		;;
	--help | -h)
		echo "Usage: $0 [--skip-loading] [--manifest-only] [--verbose] [--fail-fast]"
		exit 0
		;;
	*)
		echo "Unknown option: $1"
		exit 1
		;;
	esac
done

FAILED_TESTS=0
PASSED_TESTS=0

run_test() {
	local test_name="$1" test_script="$2" plugin_path="$3"
	if [[ ${VERBOSE} == true ]]; then
		echo "=== ${test_name} [${plugin_path}] ==="
	fi
	if "${SCRIPT_DIR}/${test_script}" "${plugin_path}"; then
		PASSED_TESTS=$((PASSED_TESTS + 1))
	else
		FAILED_TESTS=$((FAILED_TESTS + 1))
		echo "ERROR: ${test_name} failed for ${plugin_path}"
		if [[ ${FAIL_FAST} == true ]]; then
			exit 1
		fi
	fi
}

PLUGINS=()
if [[ -d plugins ]]; then
	for manifest in plugins/*/plugin.json; do
		[[ -f ${manifest} ]] || continue
		PLUGINS+=("$(dirname "${manifest}")")
	done
fi
if [[ ${#PLUGINS[@]} -eq 0 && -f plugin.json ]]; then
	PLUGINS+=(".")
fi
if [[ ${#PLUGINS[@]} -eq 0 ]]; then
	echo "No Agent Plugins manifests found."
	exit 0
fi

for plugin in "${PLUGINS[@]}"; do
	echo ">>> Testing plugin: ${plugin}"
	run_test "Agent Plugins manifest validation" "validate-manifest.sh" "${plugin}"

	# Adapter manifests are manifest-level validation and must run even in
	# --manifest-only mode.
	if [[ -d "${plugin}/.cursor-plugin" ]]; then
		run_test "Cursor manifest validation" "validate-cursor-manifest.sh" "${plugin}"
	fi
	if [[ -d "${plugin}/.codex-plugin" ]]; then
		run_test "Codex manifest validation" "validate-codex-manifest.sh" "${plugin}"
	fi

	if [[ ${MANIFEST_ONLY} == true ]]; then
		continue
	fi

	run_test "Agent Plugins MCP validation" "validate-agent-mcp.sh" "${plugin}"

	# Component discovery currently validates Claude-specific components, so a
	# portable-only Agent Plugin must not be required to provide a Claude adapter.
	if [[ -f "${plugin}/.claude-plugin/plugin.json" ]]; then
		run_test "Component discovery" "test-component-discovery.sh" "${plugin}"
		if [[ ${SKIP_LOADING} == false ]]; then
			run_test "Claude plugin loading" "test-plugin-loading.sh" "${plugin}"
		fi
	fi
done

echo "Passed: ${PASSED_TESTS}"
if [[ ${FAILED_TESTS} -gt 0 ]]; then
	echo "Failed: ${FAILED_TESTS}"
	exit 1
fi
echo "All tests passed!"
