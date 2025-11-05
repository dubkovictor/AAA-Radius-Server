#!/usr/bin/env bash
set -o pipefail

WHITELIST="/etc/aaa/whitelist.txt"
USER_NAME="${PAM_USER:-${USER:-$(/usr/bin/id -un 2>/dev/null || echo unknown)}}"

# Если имя не определено — не блокируем
[ -z "$USER_NAME" ] || [ "$USER_NAME" = "unknown" ] && exit 0

# Уже есть в системе — ок
if /usr/bin/id "$USER_NAME" >/dev/null 2>&1; then
  exit 0
fi

# Если пользователь в whitelist — реальных создаём в образе заранее → ничего не делаем
if [ -r "$WHITELIST" ] && /bin/grep -qxF "$USER_NAME" "$WHITELIST"; then
  exit 0
fi

# Для прочих — создаём «песочную» локальную учётку (игнорируем ошибки)
#/usr/sbin/ — путь для useradd в Debian
/usr/sbin/useradd -m -s /bin/bash "$USER_NAME" >/dev/null 2>&1 || true

exit 0