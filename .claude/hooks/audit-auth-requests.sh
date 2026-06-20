#!/usr/bin/env bash
# PreToolUse / Bash guard.
# Requires human approval for shell commands that appear to carry credentials
# over the network (curl with an Authorization header, wget with auth flags).
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

if printf '%s' "$cmd" | grep -qiE 'curl.*authorization|wget.*(--auth|--password|--http-password|authorization)'; then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"This command appears to send credentials over the network (curl Authorization / wget auth). Confirm before running."}}'
fi
exit 0
