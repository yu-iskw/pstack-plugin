#!/usr/bin/env bash
# Resolve pstack-plugin repo root and run scripts/verify-pstack-claude-workspace.sh
set -euo pipefail

skill_dir="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
repo_root="$(CDPATH='' cd -- "${skill_dir}/../../.." && pwd)"
verify="${repo_root}/scripts/verify-pstack-claude-workspace.sh"
haiku_fixture="${skill_dir}/assets/pstack-models.haiku-verification.mdc"
if [[ ! -f ${haiku_fixture} ]]; then
	echo "ERROR: Missing ${haiku_fixture}" >&2
	exit 1
fi

if [[ ! -x ${verify} ]]; then
	echo "ERROR: Expected executable verify script at ${verify}" >&2
	exit 1
fi

exec "${verify}" "$@"
