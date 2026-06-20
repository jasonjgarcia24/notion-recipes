#!/usr/bin/env bash
# PreToolUse / Write|Edit guard.
# Denies writes whose target path is under a shared system directory.
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"

case "$path" in
  /tmp|/tmp/*|/var/log|/var/log/*|/etc|/etc/*)
    printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Writing to system directories (/tmp, /var/log, /etc) is blocked by project policy."}}'
    ;;
esac
exit 0
