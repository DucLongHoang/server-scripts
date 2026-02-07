#!/usr/bin/env bash
#
# Hetzner VPS Initial Setup Script
# Run as root: ssh root@<ip> 'bash -s' < setup-server.sh
#
# What this does:
#   1. Creates user 'long' with sudo privileges
#   2. Copies root's authorized_keys to 'long'
#   3. Hardens SSH (disable root login, disable password auth)
#   4. Runs your harden-vps.sh for UFW + fail2ban
#
# Prerequisites:
#   - SSH key selected during Hetzner server creation
#

set -euo pipefail

USERNAME="long"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || err "Must be run as root"
[[ -f /root/.ssh/authorized_keys ]] || err "No SSH key found in /root/.ssh/authorized_keys"

# --- System update ---
log "Updating system packages..."
apt-get update -qq && apt-get upgrade -y -qq

# --- Create user ---
if id "${USERNAME}" &>/dev/null; then
  log "User '${USERNAME}' already exists"
else
  log "Creating user '${USERNAME}'..."
  useradd -m -s /bin/bash -G sudo "${USERNAME}"
  passwd -l "${USERNAME}"
fi

# --- SSH keys ---
log "Copying SSH keys to '${USERNAME}'..."
USER_HOME="/home/${USERNAME}"
mkdir -p "${USER_HOME}/.ssh"
cp /root/.ssh/authorized_keys "${USER_HOME}/.ssh/authorized_keys"
chmod 700 "${USER_HOME}/.ssh"
chmod 600 "${USER_HOME}/.ssh/authorized_keys"
chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"

# --- Passwordless sudo ---
log "Configuring passwordless sudo..."
echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"
chmod 440 "/etc/sudoers.d/${USERNAME}"

# --- Harden SSH ---
log "Hardening SSH..."
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "${SSHD_CONFIG}" "${SSHD_CONFIG}.bak"

declare -A SSH_SETTINGS=(
  ["PermitRootLogin"]="no"
  ["PasswordAuthentication"]="no"
  ["PubkeyAuthentication"]="yes"
  ["ChallengeResponseAuthentication"]="no"
  ["KbdInteractiveAuthentication"]="no"
  ["UsePAM"]="no"
  ["X11Forwarding"]="no"
  ["MaxAuthTries"]="3"
)

for key in "${!SSH_SETTINGS[@]}"; do
  value="${SSH_SETTINGS[$key]}"
  if grep -qE "^#?\s*${key}\b" "${SSHD_CONFIG}"; then
    sed -i "s/^#*\s*${key}\b.*/${key} ${value}/" "${SSHD_CONFIG}"
  else
    echo "${key} ${value}" >> "${SSHD_CONFIG}"
  fi
done

sshd -t || err "SSH config validation failed!"
systemctl restart sshd
log "SSH hardened and restarted"
echo ""
echo "=========================================="
echo " Setup Complete"
echo "=========================================="
echo ""
echo " Test in a NEW terminal:"
echo "   ssh ${USERNAME}@<server-ip>"
echo ""
echo " ⚠  Do NOT close this session until you"
echo "    confirm the new login works!"
echo "=========================================="
