#!/bin/bash

# VPS Security Hardening Script
# Sets up UFW firewall and Fail2ban with strict rules
# Usage: curl -sSL https://your-repo/harden-vps.sh | bash
# Or: chmod +x harden-vps.sh && sudo ./harden-vps.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VPS Security Hardening Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root or with sudo${NC}" 
   exit 1
fi

# Update system
echo -e "${YELLOW}[1/5] Updating system packages...${NC}"
apt update && apt upgrade -y

# Install UFW
echo -e "${YELLOW}[2/5] Installing and configuring UFW...${NC}"
apt install -y ufw

# Configure UFW
echo -e "${GREEN}Setting up firewall rules...${NC}"
ufw --force reset  # Reset to clean state
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

# Allow essential ports
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 587/tcp comment 'SMTP'

# Enable UFW
echo "y" | ufw enable

echo -e "${GREEN}UFW Status:${NC}"
ufw status verbose

# Install Fail2ban
echo -e "${YELLOW}[3/5] Installing Fail2ban...${NC}"
apt install -y fail2ban

# Create jail.local with strict rules
echo -e "${YELLOW}[4/5] Configuring Fail2ban with strict rules...${NC}"
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
# Ignore local connections
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
findtime = 3600
maxretry = 3
bantime = 3600
bantime.increment = true
bantime.rndtime = 300
bantime.maxtime = 31536000
bantime.factor = 2
bantime.formula = ban.Time * (1<<(ban.Count if ban.Count<20 else 20)) * banFactor
EOF

# Enable and start Fail2ban
systemctl enable fail2ban
systemctl restart fail2ban

# Wait a moment for fail2ban to start
sleep 2

echo -e "${YELLOW}[5/5] Verifying installation...${NC}"
echo ""

# Check UFW status
echo -e "${GREEN}✓ UFW Firewall Status:${NC}"
ufw status numbered
echo ""

# Check Fail2ban status
echo -e "${GREEN}✓ Fail2ban Status:${NC}"
fail2ban-client status
echo ""

# Check SSH jail
echo -e "${GREEN}✓ SSH Jail Status:${NC}"
fail2ban-client status sshd 2>/dev/null || echo "SSH jail starting..."
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Security Hardening Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Configured Rules:${NC}"
echo "  • UFW Firewall: Active"
echo "  • Allowed Ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 587 (SMTP)"
echo "  • Fail2ban: Active with progressive banning"
echo "  • SSH Protection: 3 attempts per hour"
echo "  • Ban Time: 1 hour (doubles on repeat, max 1 year)"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo "  • Test SSH access before closing this session!"
echo "  • Add your IP to ignoreip in /etc/fail2ban/jail.local if needed"
echo "  • Monitor with: sudo fail2ban-client status sshd"
echo ""
echo -e "${GREEN}Hardening completed successfully!${NC}"
