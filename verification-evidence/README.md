# Verification evidence (local, not committed)

Operator logs from comprehensive Claude Code verification. Git ignores `*.log` here.

```bash
make verify-pstack-claude   # once
export PSTACK_VERIFY_MODEL='claude-haiku-4-5@20251001'   # Vertex: use id from CLI hint
make verify-pstack-claude-live-record
```

If you see a **workspace trust** error, run `claude` interactively once in the repo and accept trust, then retry.

Validate a log:

```bash
./scripts/validate-pstack-live-log.sh verification-evidence/live-<timestamp>.log
```

Paste the generated log into a PR or goal thread. See [COMPLETION-AUDIT-STATUS.md](./COMPLETION-AUDIT-STATUS.md) for required tokens.
