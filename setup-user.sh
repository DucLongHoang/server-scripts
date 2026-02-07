#!/usr/bin/env bash
#
# Hetzner VPS User Setup Script
# Called by bootstrap.sh — expects SETUP_USERNAME and SETUP_PASSWORD env vars
#

set -euo pipefail

USERNAME="${SETUP_USERNAME:-}"
PASSWORD="${SETUP_PASSWORD:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || err "Must be run as root"
[[ -n "${USERNAME}" ]] || err "SETUP_USERNAME not set"
[[ -n "${PASSWORD}" ]] || err "SETUP_PASSWORD not set"
[[ -f /root/.ssh/authorized_keys ]] || err "No SSH key found in /root/.ssh/authorized_keys"

# --- Detect SSH service name ---
if systemctl list-unit-files | grep -q 'sshd.service'; then
  SSH_SERVICE="sshd"
elif systemctl list-unit-files | grep -q 'ssh.service'; then
  SSH_SERVICE="ssh"
else
  err "Could not find SSH service"
fi

log "Setting up user '${USERNAME}' with SSH service '${SSH_SERVICE}'"

# --- System update ---
log "Updating system packages..."
apt-get update -qq && NEEDRESTART_MODE=a apt-get upgrade -y -qq

# --- Create user ---
if id "${USERNAME}" &>/dev/null; then
  log "User '${USERNAME}' already exists"
else
  log "Creating user '${USERNAME}'..."
  useradd -m -s /bin/bash -G sudo "${USERNAME}"
fi

# --- Set password (for Hetzner console emergency access) ---
log "Setting password for '${USERNAME}' (Hetzner console emergency access)..."
echo "${USERNAME}:${PASSWORD}" | chpasswd
warn "SSH password login will be disabled — this password is for console access only"

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
systemctl restart "${SSH_SERVICE}"
log "SSH hardened and restarted (${SSH_SERVICE}.service)"

echo ""
echo "=========================================="
echo " User Setup Complete"
echo "=========================================="
echo ""
echo " Test in a NEW terminal:"
echo "   ssh ${USERNAME}@<server-ip>"
echo ""
echo " ⚠  Do NOT close this session until you"
echo "    confirm the new login works!"
echo "=========================================="
