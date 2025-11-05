#!/usr/bin/env bash
set -euo pipefail

# 1) Подстраховка: создадим базовые каталоги
mkdir -p /etc/aaa /var/log/aaa
chmod 1777 /var/log/aaa

# 2) Если указан SSH_ANY_USER=1 — создать «ловушечную» учётку для последнего пробовавшего юзера.
#   Мы будем перехватывать имя через AuthorizedKeysCommand невозможно для пароля,
#   поэтому используем «массовое» авто-создание: заранее подготовим несколько песочных юзеров.
for u in guest1 guest2 guest3 guest4 guest5; do
  id "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u" || true
done

# Запуск sshd в Foreground
exec /usr/sbin/sshd -D -e