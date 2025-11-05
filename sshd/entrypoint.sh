#!/usr/bin/env bash
set -euo pipefail

# 1) Safety net: create base directories
mkdir -p /etc/aaa /var/log/aaa
chmod 1777 /var/log/aaa

# 2) If SSH_ANY_USER=1 is set, create a honeypot account for the last attempted user.
#   We'll intercept the username via AuthorizedKeysCommand, which is impossible for password auth,
#   so we bulk auto-create several sandbox users in advance.
for u in guest1 guest2 guest3 guest4 guest5; do
  id "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u" || true
done

# Start sshd in the foreground
exec /usr/sbin/sshd -D -e
