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

.PHONY: lint
lint:
	trunk check --all -y

.PHONY: format
format:
	trunk fmt --all

.PHONY: test-integration-docker
test-integration-docker:
	docker build -f integration_tests/Dockerfile -t claude-plugin-template-smoke .
	docker run --rm claude-plugin-template-smoke

.PHONY: verify-pstack-claude verify-pstack-claude-live
verify-pstack-claude:
	./scripts/verify-pstack-claude-workspace.sh

verify-pstack-claude-live:
	./scripts/verify-pstack-claude-workspace.sh --live

verify-pstack-claude-live-only:
	./scripts/verify-pstack-claude-workspace.sh --live-only

.PHONY: verify-pstack-claude-live-record
verify-pstack-claude-live-record:
	./scripts/operator-run-live-smoke.sh
