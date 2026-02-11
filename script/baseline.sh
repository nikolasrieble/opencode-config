#!/usr/bin/env bash
#
# baseline.sh — Regression guard for the default session context size
#
# The baseline is the number of input tokens OpenCode sends on the first turn
# of a default (build) session: the system prompt plus all tool definitions.
# Our config should not inflate this number. Custom agents, disabled MCP tools,
# and config values like model/compaction/theme do not contribute to it.
#
# If the baseline increases after a config change, something is leaking into
# the default context — e.g., globally enabled tools or a future config feature
# that injects instructions into the system prompt.
#
# The expected baseline is determined by the OpenCode version, not by our config.
# A stable number confirms our config stays out of the way.
#
# Requires: opencode, jq
#
set -euo pipefail

command -v opencode &>/dev/null || { echo "error: opencode not found" >&2; exit 1; }
command -v jq &>/dev/null       || { echo "error: jq not found" >&2; exit 1; }

TOKENS=$(opencode run "hi" --format json 2>/dev/null \
  | grep '"step_finish"' \
  | head -1 \
  | jq '.part.tokens | .input + .cache.read')

[[ -n "$TOKENS" && "$TOKENS" != "null" ]] || { echo "error: could not extract tokens" >&2; exit 1; }

echo "$TOKENS"
