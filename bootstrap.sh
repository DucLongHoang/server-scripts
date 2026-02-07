#!/usr/bin/env bash

set -euo pipefail

REPO="https://raw.githubusercontent.com/duclonghoang/server-scripts/main"

echo "=== Running setup-user.sh ==="
curl -sSL "${REPO}/setup-user.sh" | bash

echo "=== Running setup-security.sh ==="
curl -sSL "${REPO}/setup-security.sh" | bash

echo "=== Running setup-zsh.sh ==="
# Run as 'long' since oh-my-zsh is per-user
curl -sSL "${REPO}/setup-zsh.sh" | su - long -c 'bash -s'

echo "=== Running setup-docker.sh ==="
curl -sSL "${REPO}/setup-docker.sh" | bash

echo "=== All done ==="
