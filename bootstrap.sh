#!/usr/bin/env bash
#
# Bootstrap script for fresh Hetzner VPS setup
# Usage: bash bootstrap.sh <username> <password>
#

set -euo pipefail

USERNAME="${1:-}"
PASSWORD="${2:-}"

[[ -n "${USERNAME}" ]] || { echo "Usage: bash bootstrap.sh <username> <password>"; exit 1; }
[[ -n "${PASSWORD}" ]] || { echo "Usage: bash bootstrap.sh <username> <password>"; exit 1; }

export SETUP_USERNAME="${USERNAME}"
export SETUP_PASSWORD="${PASSWORD}"

REPO="https://raw.githubusercontent.com/DucLongHoang/server-scripts/refs/heads/master"

echo "=== Running setup-user.sh ==="
curl -sSL "${REPO}/setup-user.sh" | bash

echo "=== Running setup-security.sh ==="
curl -sSL "${REPO}/setup-security.sh" | bash

echo "=== Running setup-docker.sh ==="
curl -sSL "${REPO}/setup-docker.sh" | bash

echo ""
echo "=========================================="
echo " Bootstrap Complete!"
echo "=========================================="
echo ""
echo " 1. Test SSH in a new terminal:"
echo "    ssh ${USERNAME}@<server-ip>"
echo ""
echo " 2. Then run the zsh setup as ${USERNAME}:"
echo "    curl -sSL ${REPO}/setup-zsh.sh | bash"
echo ""
echo " 3. Reboot to load the new kernel:"
echo "    sudo reboot"
echo ""
echo "=========================================="
