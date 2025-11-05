FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server libpam-radius-auth ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Basic SSHD setup
RUN mkdir -p /var/run/sshd /root/.ssh

# PAM RADIUS config
COPY pam_radius_auth.conf /etc/pam_radius_auth.conf

# PAM stack for sshd
COPY pam_sshd /etc/pam.d/sshd

# sshd config
COPY sshd_config /etc/ssh/sshd_config

COPY aaa-gateway.sh /usr/local/bin/aaa-gateway.sh
COPY fake_shell.sh  /usr/local/bin/fake_shell.sh
#COPY ensure_user.sh /usr/local/bin/ensure_user.sh
RUN chmod +x /usr/local/bin/aaa-gateway.sh /usr/local/bin/fake_shell.sh /usr/local/bin/ensure_user.sh

COPY ensure_user.sh /usr/local/bin/ensure_user.sh
RUN chmod +x /usr/local/bin/ensure_user.sh
# and make sure the /etc/aaa directory exists (for the whitelist bind mount)
RUN mkdir -p /etc/aaa /var/log/aaa && chmod 1777 /var/log/aaa

RUN mkdir -p /var/log/aaa && chmod 1777 /var/log/aaa

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# For the demo, allow login even if the local user does not exist.
# Create "sandbox" as a fallback (optional but handy).
RUN useradd -m -s /bin/bash sandbox || true \
 && useradd -m -s /bin/bash viktor  || true \
 && useradd -m -s /bin/bash mihai   || true \
 && useradd -m -s /bin/bash nelly   || true

RUN mkdir -p /etc/aaa \
 && mkdir -p /var/log/aaa && chmod 1777 /var/log/aaa

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
