# AAA RADIUS Server Stack

## Overview
This repository contains a demo AAA (Authentication, Authorization, Accounting) environment built around FreeRADIUS. It showcases how a web application and an SSH bastion can delegate authentication to a shared RADIUS backend while handling non-whitelisted users safely via a honeypot shell.

## Components
- `radius`: FreeRADIUS server configured with sample clients, shared secrets, and demo users.
- `webapp`: Flask application that authenticates through RADIUS and shows either real or fake data depending on the login result.
- `sshd`: OpenSSH server that authenticates against RADIUS, drops non-whitelisted users into a fake sandbox shell, and logs every attempt.

## How It Works
1. Users submit credentials either through the web page or by connecting over SSH.
2. Both frontends send an Access-Request to the RADIUS server using their configured shared secrets.
3. FreeRADIUS validates the request against `radius/users` and returns `Access-Accept` for known users or `Access-Reject` otherwise.
4. Successful logins reach the "real" content; everyone else is redirected to the fake dataset or fake shell.

## Prerequisites
- Docker Engine 20.10 or newer.
- Docker Compose plugin v2 (usually available by default with modern Docker installations).

## Running the Stack
From the project root:

```bash
docker compose pull        # optional: fetch latest upstream images
docker compose build       # builds the webapp and sshd images
docker compose up -d       # starts radius, webapp, and sshd
```

The compose file exposes the following ports on the host:
- `8080/tcp` → web application (Flask)
- `2222/tcp` → SSH service
- `1812/udp`, `1813/udp` → RADIUS authentication and accounting

## Trying It Out
- **Web:** open `http://localhost:8080` and authenticate with demo accounts such as `viktor/pass`, `mihai/pass`, or `nelly/pass`. Invalid credentials route you to the fake data page.
- **SSH:** connect with `ssh viktor@localhost -p 2222`. Users listed in `radius/whitelist.txt` receive their normal shell; everyone else lands in a logged fake shell.

Sample credentials live in `radius/users`. Update that file and the matching shared secrets in `radius/clients.conf` if you deploy beyond local testing.

## Managing the Environment
- View logs:
  ```bash
  docker compose logs -f
  ```
- Stop services:
  ```bash
  docker compose down
  ```
- Remove volumes and images (if you want a clean slate):
  ```bash
  docker compose down -v --rmi local
  ```

## Next Steps
- Customize the whitelist at `radius/whitelist.txt` for SSH access control.
- Switch the shared secrets in `radius/clients.conf` and the corresponding environment variables before using in production.
- Place the web application behind a TLS-terminating reverse proxy for secure deployments.
