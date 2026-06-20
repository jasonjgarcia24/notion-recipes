#!/usr/bin/env bash
# PostToolUse / Bash tripwire.
# Scans the command's output for credential-shaped patterns and warns WITHOUT
# echoing the match. This is a backstop, not a guarantee: PostToolUse fires after
# the command has already run, so it cannot un-print output already captured.
# It exists to flag that a secret-shaped value appeared, so it can be rotated.
set -euo pipefail

input="$(cat)"
resp="$(printf '%s' "$input" | jq -r '.tool_response | if type=="string" then . else tostring end' 2>/dev/null || true)"

if printf '%s' "$resp" | grep -qiE 'password|token|secret|api[_-]?key'; then
  # Emit a warning only. Never include the matched value.
  printf '%s' '{"systemMessage":"⚠ Bash output matched a credential-shaped pattern (password/token/secret/api_key). Value withheld. If this is a live secret, rotate it and keep it out of the conversation.","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"A credential-shaped pattern was detected in the previous Bash output. Do not echo or repeat the matched value; if it is a real secret, advise rotation."}}'
fi
exit 0
