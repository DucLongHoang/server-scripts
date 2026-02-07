# server-scripts

Opinionated setup scripts for bootstrapping a fresh Hetzner VPS. Creates a non-root user, hardens SSH, configures UFW + fail2ban, installs Docker, and sets up a dev-friendly shell — all in one go.

## Usage

```bash
git clone https://github.com/duclonghoang/server-scripts.git /tmp/setup
cd /tmp/setup
sudo bash bootstrap.sh
rm -rf /tmp/setup
```

## What's included

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Orchestrator — runs all scripts in order |
| `setup-user.sh` | Creates user, copies SSH keys, hardens sshd |
| `harden-vps.sh` | UFW firewall + fail2ban with progressive banning |
| `setup-docker.sh` | Docker Engine + Compose plugin, rootless for user |
| `setup-zsh.sh` | Zsh + Oh My Zsh |

## Assumptions

- Fresh Ubuntu server on Hetzner
- SSH key added during server creation
- Run as root
