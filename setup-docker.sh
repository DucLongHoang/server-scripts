#!/usr/bin/env bash
#
# Docker + Docker Compose Setup Script
# Called by bootstrap.sh — expects SETUP_USERNAME env var
#

set -euo pipefail

USERNAME="${SETUP_USERNAME:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

[[ "$(id -u)" -eq 0 ]] || err "Must be run as root"
[[ -n "${USERNAME}" ]] || err "SETUP_USERNAME not set"

# --- Install prerequisites ---
log "Installing prerequisites..."
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg

# --- Add Docker's official GPG key ---
log "Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# --- Add Docker repository ---
log "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Install Docker Engine + Compose plugin ---
log "Installing Docker Engine and Compose plugin..."
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Add user to docker group ---
log "Adding '${USERNAME}' to docker group..."
usermod -aG docker "${USERNAME}"

# --- Enable Docker on boot ---
log "Enabling Docker service..."
systemctl enable docker
systemctl start docker

# --- Verify ---
log "Docker version:"
docker --version
docker compose version

echo ""
echo "=========================================="
echo " Docker Setup Complete"
echo "=========================================="
echo ""
echo " '${USERNAME}' can now run docker without sudo."
echo ""
echo " ⚠  Log out and back in for group to apply,"
echo "    or run: newgrp docker"
echo "=========================================="
