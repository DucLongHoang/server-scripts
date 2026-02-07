# server-scripts

Opinionated setup scripts for bootstrapping a fresh Hetzner VPS. Creates a non-root user, hardens SSH, configures UFW + fail2ban, installs Docker, and sets up a dev-friendly shell — all in one go.

## Usage

```bash
curl -sSLO https://raw.githubusercontent.com/DucLongHoang/server-scripts/refs/heads/master/bootstrap.sh
bash bootstrap.sh username userpassword
rm bootstrap.sh
```

## What's included

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Orchestrator — runs all scripts in order |
| `setup-user.sh` | Creates user, copies SSH keys, hardens sshd |
| `setup-security.sh` | UFW firewall + fail2ban with progressive banning |
| `setup-docker.sh` | Docker Engine + Compose plugin, rootless for user |
| `setup-zsh.sh` | Zsh + Oh My Zsh |

## Assumptions

- Fresh Ubuntu server on Hetzner
- SSH key added during server creation
- Run as root
