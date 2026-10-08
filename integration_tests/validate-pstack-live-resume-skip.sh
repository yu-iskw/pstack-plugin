#!/usr/bin/env bash
# Resume must not treat prompt lines that mention a token as completed steps.
set -euo pipefail

TMP="$(mktemp)"
cat >"${TMP}" <<'EOF'
    prompt: End with SLASH_POTETO_MODE=ok on its own line
    expect token: SLASH_POTETO_MODE=ok
SLASH_POTETO_HELP=ok
EOF

if grep -Fq 'SLASH_POTETO_MODE=ok' "${TMP}" && ! grep -Fxq 'SLASH_POTETO_MODE=ok' "${TMP}"; then
	: # old broken -Fq would match prompt substring
else
	echo "ERROR: expected prompt-only substring without exact line" >&2
	exit 1
fi

if grep -Fxq 'SLASH_POTETO_MODE=ok' "${TMP}"; then
	echo "ERROR: exact-line grep should not match yet" >&2
	exit 1
fi

if ! grep -Fxq 'SLASH_POTETO_HELP=ok' "${TMP}"; then
	echo "ERROR: exact-line grep should match completed token" >&2
	exit 1
fi

rm -f "${TMP}"
echo "live resume skip exact-line policy OK."
