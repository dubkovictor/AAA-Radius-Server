FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server libpam-radius-auth ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# SSHD базовая настройка
RUN mkdir -p /var/run/sshd /root/.ssh

# PAM RADIUS конфиг
COPY pam_radius_auth.conf /etc/pam_radius_auth.conf

# PAM стек для sshd
COPY pam_sshd /etc/pam.d/sshd

# Конфиг sshd
COPY sshd_config /etc/ssh/sshd_config

COPY aaa-gateway.sh /usr/local/bin/aaa-gateway.sh
COPY fake_shell.sh  /usr/local/bin/fake_shell.sh
#COPY ensure_user.sh /usr/local/bin/ensure_user.sh
RUN chmod +x /usr/local/bin/aaa-gateway.sh /usr/local/bin/fake_shell.sh /usr/local/bin/ensure_user.sh

COPY ensure_user.sh /usr/local/bin/ensure_user.sh
RUN chmod +x /usr/local/bin/ensure_user.sh
# и убедитесь, что есть каталог /etc/aaa (для whitelist bind-mount)
RUN mkdir -p /etc/aaa /var/log/aaa && chmod 1777 /var/log/aaa

RUN mkdir -p /var/log/aaa && chmod 1777 /var/log/aaa

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Для демо: позволим вход даже если локального пользователя нет.
# Создадим "sandbox" как fallback (необязательно, но удобно).
RUN useradd -m -s /bin/bash sandbox || true \
 && useradd -m -s /bin/bash viktor  || true \
 && useradd -m -s /bin/bash mihai   || true \
 && useradd -m -s /bin/bash nelly   || true

RUN mkdir -p /etc/aaa \
 && mkdir -p /var/log/aaa && chmod 1777 /var/log/aaa

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
