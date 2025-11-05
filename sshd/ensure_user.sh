#!/usr/bin/env bash
set -o pipefail

WHITELIST="/etc/aaa/whitelist.txt"
USER_NAME="${PAM_USER:-${USER:-$(/usr/bin/id -un 2>/dev/null || echo unknown)}}"

# If the name is missing, do not block
[ -z "$USER_NAME" ] || [ "$USER_NAME" = "unknown" ] && exit 0

# Already exists in the system — fine
if /usr/bin/id "$USER_NAME" >/dev/null 2>&1; then
  exit 0
fi

# If the user is in the whitelist, real accounts are pre-created in the image, so do nothing
if [ -r "$WHITELIST" ] && /bin/grep -qxF "$USER_NAME" "$WHITELIST"; then
  exit 0
fi

# For the rest, create a sandbox local account (ignore errors)
# /usr/sbin/ — path to useradd on Debian
/usr/sbin/useradd -m -s /bin/bash "$USER_NAME" >/dev/null 2>&1 || true

exit 0
