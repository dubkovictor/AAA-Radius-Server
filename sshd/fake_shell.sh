#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
================================================================
 FAKE DATA MODE
================================================================
Вы не являетесь авторизованным пользователем. Предоставляются
только тестовые «фейковые» данные. Любая деятельность логируется.
EOF

# Simple "shell"
while true; do
  printf "\n(fake)> "
  if ! read -r cmd; then break; fi
  case "$cmd" in
    exit|quit) break ;;
    info) echo "Demo: fake dataset v1.0";;
    help|?) echo "Команды: info, help, exit";;
    *) echo "Команда недоступна в fake-режиме. help для списка.";;
  esac
done
