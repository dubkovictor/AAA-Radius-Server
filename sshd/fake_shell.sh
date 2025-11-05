#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
================================================================
 This is a honeypot SSH server running a fake shell.
 Any commands you enter will not affect a real system.
================================================================

EOF

# Simple "shell"
while true; do
  printf "\n(fake)> "
  if ! read -r cmd; then break; fi
  case "$cmd" in
    exit|quit) break ;;
    info) echo "Demo: fake dataset v1.0";;
    help|?) echo "Commands: info, help, exit";;
    *) echo "The command is not available in fake mode. Use help for a list.";;
  esac
done
