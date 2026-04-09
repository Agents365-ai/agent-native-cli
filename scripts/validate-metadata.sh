#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

assert_contains() {
  local file="$1"
  local pattern="$2"

  if ! rg -q --fixed-strings "$pattern" "$file"; then
    echo "Missing expected text in $file: $pattern" >&2
    exit 1
  fi
}

assert_contains README.md '~/.codex/skills/agent-native-cli'
assert_contains README.md '.codex/skills/agent-native-cli'
assert_contains README_CN.md '~/.codex/skills/agent-native-cli'
assert_contains README_CN.md '.codex/skills/agent-native-cli'

assert_contains SKILL.md 'Includes sidecar metadata for OpenClaw, Hermes, pi-mono, and OpenAI Codex'
assert_contains README.md 'includes metadata for the platforms listed below'
assert_contains README_CN.md '并为下列平台提供元数据'

assert_contains SKILL.md 'Use the 10-criterion rubric to score the CLI.'
assert_contains SKILL.md 'Report the 10-criterion rubric score first'
assert_contains agents/openai.yaml 'Score a CLI on the 10-criterion rubric and summarize the seven design principles'

test -f LICENSE || {
  echo 'LICENSE file is missing' >&2
  exit 1
}

echo 'Metadata validation passed.'
