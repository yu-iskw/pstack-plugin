FROM node:20-alpine

WORKDIR /workspace

# Install shell/runtime dependencies and Claude Code CLI
RUN apk add --no-cache bash jq && \
    npm install -g @anthropic-ai/claude-code

# Copy plugin structure and marketplace manifest (for install test at runtime)
COPY plugins/ plugins/
COPY .claude-plugin/ .claude-plugin/
COPY LICENSE LICENSE
COPY scripts/ scripts/
COPY .claude/skills/try-pstack-claude/assets/ .claude/skills/try-pstack-claude/assets/
COPY integration_tests/fixtures/ integration_tests/fixtures/
COPY verification-evidence/ verification-evidence/

# Copy test scripts
COPY integration_tests/*.sh /workspace/integration_tests/
RUN chmod +x /workspace/integration_tests/*.sh && \
	chmod +x /workspace/scripts/*.sh /workspace/scripts/lib/*.sh 2>/dev/null || true

# Run integration tests for all plugins during build
RUN /workspace/integration_tests/run.sh

RUN addgroup -S app && adduser -S -G app app && chown -R app:app /workspace

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD claude --version >/dev/null 2>&1 || exit 1

USER app

CMD ["/workspace/integration_tests/docker-entrypoint.sh"]
