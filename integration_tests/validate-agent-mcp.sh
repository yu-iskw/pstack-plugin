#!/usr/bin/env bash

set -euo pipefail

PLUGIN_DIR="${1:-.}"
MCP_PATH="${PLUGIN_DIR}/mcp.json"
EXPECTED_SCHEMA="https://agent-plugins.org/schemas/1.0.0/mcp.schema.json"

if [[ ! -e ${MCP_PATH} ]]; then
	echo "No portable mcp.json; skipping MCP validation."
	exit 0
fi
if [[ ! -f ${MCP_PATH} ]]; then
	echo "ERROR: ${MCP_PATH} must be a regular file."
	exit 1
fi

node - "${MCP_PATH}" "${EXPECTED_SCHEMA}" <<'EOF'
const fs = require("fs");
const [mcpPath, expectedSchema] = process.argv.slice(2);
let config;
try {
  config = JSON.parse(fs.readFileSync(mcpPath, "utf8"));
} catch (error) {
  console.error(`ERROR: Invalid JSON in ${mcpPath}: ${error.message}`);
  process.exit(1);
}
if (!config || Array.isArray(config) || typeof config !== "object") {
  console.error("ERROR: mcp.json must contain an object.");
  process.exit(1);
}
if (config.$schema !== expectedSchema) {
  console.error(`ERROR: $schema must equal ${expectedSchema}.`);
  process.exit(1);
}
if (Object.keys(config).some((key) => !["$schema", "mcpServers"].includes(key))) {
  console.error("ERROR: mcp.json has unknown top-level fields.");
  process.exit(1);
}
if (!config.mcpServers || Array.isArray(config.mcpServers) || typeof config.mcpServers !== "object") {
  console.error("ERROR: mcpServers must be an object.");
  process.exit(1);
}
const pluginRelative = (value) => value.startsWith("./") && !value.split(/[\\/]+/).includes("..");
for (const [name, server] of Object.entries(config.mcpServers)) {
  if (!server || Array.isArray(server) || typeof server !== "object") {
    throw new Error(`${name}: server must be an object`);
  }
  if (!["stdio", "streamable-http", "sse"].includes(server.type)) {
    throw new Error(`${name}: invalid transport '${server.type}'`);
  }
  if (server.type === "stdio") {
    const allowed = new Set(["type", "command", "args", "env", "cwd"]);
    if (Object.keys(server).some((key) => !allowed.has(key))) throw new Error(`${name}: unknown stdio field`);
    if (typeof server.command !== "string" || !server.command) throw new Error(`${name}: command is required`);
    if (server.command.includes("/") || server.command.includes("\\")) {
      if (!pluginRelative(server.command)) throw new Error(`${name}: plugin command must begin with ./ and remain contained`);
    }
    if (server.args !== undefined && (!Array.isArray(server.args) || server.args.some((arg) => typeof arg !== "string"))) throw new Error(`${name}: args must be strings`);
    if (server.env !== undefined) {
      if (!server.env || Array.isArray(server.env) || typeof server.env !== "object") throw new Error(`${name}: env must be an object`);
      if (Object.keys(server.env).some((key) => ["PLUGIN_ROOT", "PLUGIN_DATA"].includes(key))) throw new Error(`${name}: reserved environment variable override`);
      if (Object.values(server.env).some((value) => typeof value !== "string")) throw new Error(`${name}: env values must be strings`);
    }
    if (server.cwd !== undefined) {
      if (typeof server.cwd !== "string") throw new Error(`${name}: cwd must be a string`);
      const validCwd = server.cwd === "${PLUGIN_ROOT}" || server.cwd === "${PLUGIN_DATA}" || server.cwd.startsWith("${PLUGIN_ROOT}/") || server.cwd.startsWith("${PLUGIN_DATA}/") || pluginRelative(server.cwd);
      if (!validCwd || server.cwd.split(/[\\/]+/).includes("..")) throw new Error(`${name}: invalid cwd`);
    }
  } else {
    const allowed = new Set(["type", "url", "headers"]);
    if (Object.keys(server).some((key) => !allowed.has(key))) throw new Error(`${name}: unknown HTTP field`);
    if (typeof server.url !== "string" || !server.url) throw new Error(`${name}: url is required`);
    const url = new URL(server.url);
    const loopback = ["localhost", "127.0.0.1", "::1"].includes(url.hostname);
    if (url.protocol !== "https:" && !(url.protocol === "http:" && loopback)) throw new Error(`${name}: non-loopback MCP URLs must use HTTPS`);
  }
}
console.log(`Agent Plugins MCP validation passed: ${Object.keys(config.mcpServers).length} server(s)`);
EOF
