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

PLUGIN_DIR="${1:-.}"
MANIFEST_PATH="${PLUGIN_DIR}/plugin.json"
EXPECTED_SCHEMA="https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"

if [[ ! -f ${MANIFEST_PATH} ]]; then
	echo "ERROR: Agent Plugins manifest not found: ${MANIFEST_PATH}"
	exit 1
fi

node - "${MANIFEST_PATH}" "${EXPECTED_SCHEMA}" <<'EOF'
const fs = require("fs");
const [manifestPath, expectedSchema] = process.argv.slice(2);
const allowed = new Set([
  "$schema", "name", "version", "description", "author", "homepage",
  "repository", "license", "keywords", "extensions"
]);
let manifest;
try {
  manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
} catch (error) {
  console.error(`ERROR: Invalid JSON in ${manifestPath}: ${error.message}`);
  process.exit(1);
}
if (!manifest || Array.isArray(manifest) || typeof manifest !== "object") {
  console.error(`ERROR: ${manifestPath} must contain a JSON object.`);
  process.exit(1);
}
if (manifest.$schema !== expectedSchema) {
  console.error(`ERROR: $schema must equal ${expectedSchema}.`);
  process.exit(1);
}
for (const field of ["name", "version", "description"]) {
  if (typeof manifest[field] !== "string" || manifest[field].trim() === "") {
    console.error(`ERROR: ${field} must be a required non-empty string.`);
    process.exit(1);
  }
}
if (!/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/.test(manifest.name)) {
  console.error(`ERROR: invalid plugin name: ${manifest.name}`);
  process.exit(1);
}
for (const [key, value] of Object.entries(manifest)) {
  if (!allowed.has(key)) {
    console.error(`ERROR: unknown top-level field '${key}' in ${manifestPath}.`);
    process.exit(1);
  }
  if (["homepage", "repository", "license"].includes(key) && typeof value !== "string") {
    console.error(`ERROR: ${key} must be a string.`);
    process.exit(1);
  }
}
if (manifest.author !== undefined) {
  if (!manifest.author || Array.isArray(manifest.author) || typeof manifest.author !== "object") {
    console.error("ERROR: author must be an object.");
    process.exit(1);
  }
  for (const key of Object.keys(manifest.author)) {
    if (!["name", "email", "url"].includes(key) || typeof manifest.author[key] !== "string") {
      console.error(`ERROR: invalid author field '${key}'.`);
      process.exit(1);
    }
  }
}
if (manifest.keywords !== undefined && (!Array.isArray(manifest.keywords) || manifest.keywords.some((v) => typeof v !== "string"))) {
  console.error("ERROR: keywords must be an array of strings.");
  process.exit(1);
}
if (manifest.extensions !== undefined && (!manifest.extensions || Array.isArray(manifest.extensions) || typeof manifest.extensions !== "object")) {
  console.error("ERROR: extensions must be an object when present.");
  process.exit(1);
}
console.log(`Agent Plugins manifest validation passed: ${manifest.name}`);
EOF
