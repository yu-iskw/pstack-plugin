# shellcheck shell=bash
# Prepare a temporary HOME with haiku-only pstack-models.mdc; symlink OAuth/plugins from real ~/.claude.
# Source from verify --live and interactive haiku launcher. Not for direct execution.

pstack_haiku_temp_home_prepare() {
	local fixture="$1"
	if [[ ! -f ${fixture} ]]; then
		echo "ERROR: Missing haiku fixture: ${fixture}" >&2
		return 1
	fi

	PSTACK_REAL_HOME="${HOME}"
	PSTACK_TMP_HOME="$(mktemp -d)"
	PSTACK_TMP_CLAUDE="${PSTACK_TMP_HOME}/.claude"
	mkdir -p "${PSTACK_TMP_CLAUDE}"
	cp "${fixture}" "${PSTACK_TMP_CLAUDE}/pstack-models.mdc"
	# Claude Code does not auto-apply pstack-models like Cursor .mdc rules; load via @ include.
	cat >"${PSTACK_TMP_CLAUDE}/CLAUDE.md" <<'EOF'
# pstack haiku verification (temporary session HOME — not your real ~/.claude)

@~/.claude/pstack-models.mdc
EOF

	local real_claude="${PSTACK_REAL_HOME}/.claude"
	if [[ -d ${real_claude} ]]; then
		local item
		for item in plugins cache; do
			if [[ -e ${real_claude}/${item} ]]; then
				ln -sfn "${real_claude}/${item}" "${PSTACK_TMP_CLAUDE}/${item}"
			fi
		done
		for item in settings.json settings.local.json; do
			if [[ -f ${real_claude}/${item} ]]; then
				ln -sfn "${real_claude}/${item}" "${PSTACK_TMP_CLAUDE}/${item}"
			fi
		done
	fi

	if [[ -f ${PSTACK_REAL_HOME}/.claude.json ]]; then
		ln -sfn "${PSTACK_REAL_HOME}/.claude.json" "${PSTACK_TMP_HOME}/.claude.json"
	fi

	export PSTACK_REAL_HOME PSTACK_TMP_HOME PSTACK_TMP_CLAUDE
}

pstack_haiku_temp_home_cleanup() {
	if [[ -n ${PSTACK_TMP_HOME-} && -d ${PSTACK_TMP_HOME} ]]; then
		rm -rf "${PSTACK_TMP_HOME}" 2>/dev/null || true
	fi
}
