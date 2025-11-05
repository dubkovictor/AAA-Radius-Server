#!/usr/bin/env bash
set -uo pipefail   # dropped -e to avoid failing on non-critical errors

WHITELIST="/etc/aaa/whitelist.txt"
REAL_SHELL="${SHELL:-/bin/bash}"
LOG_DIR="/var/log/aaa"
LOG_FILE="$LOG_DIR/aaa_gateway.log"

resolve_username() {
  local candidate
  for candidate in "$(id -un 2>/dev/null || true)" "${PAM_USER:-}" "${USER:-}" "$(whoami 2>/dev/null || true)"; do
    if [ -n "$candidate" ] && [ "$candidate" != "true" ]; then
      printf "%s" "$candidate" | tr -d '\r\n'
      return 0
    fi
  done
  printf "unknown"
}

is_whitelisted() {
  local candidate trimmed
  [ -r "$WHITELIST" ] || return 1

  while IFS= read -r candidate || [ -n "$candidate" ]; do
    candidate="${candidate%%#*}"                  # strip the comment
    trimmed="$(printf "%s" "$candidate" | tr -d ' \t\r\n')"
    [ -z "$trimmed" ] && continue
    if [ "$trimmed" = "$1" ]; then
      return 0
    fi
  done < "$WHITELIST"
  return 1
}

USER_NAME="$(resolve_username)"

# Write a log entry, but never fail if something goes wrong
{ mkdir -p "$LOG_DIR" 2>/dev/null || true; }
{ printf "%s - SSH login attempt for user='%s' from %s\n" \
        "$(date -Is)" "$USER_NAME" "${SSH_CLIENT:-unknown}" \
        >> "$LOG_FILE" 2>/dev/null || true; }

if is_whitelisted "$USER_NAME"; then
  { printf "%s - user '%s' in whitelist, launching real shell\n" "$(date -Is)" "$USER_NAME" >> "$LOG_FILE" 2>/dev/null || true; }
  exec "$REAL_SHELL" -l
else
  { printf "%s - user '%s' NOT in whitelist, launching fake shell\n" "$(date -Is)" "$USER_NAME" >> "$LOG_FILE" 2>/dev/null || true; }
  exec /usr/local/bin/fake_shell.sh
fi
