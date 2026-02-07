#!/bin/bash

# Terminal Enhancement Setup Script
# Run as your user (not root): bash setup-zsh.sh

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Terminal Enhancement Setup Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Update package list
echo -e "${GREEN}[1/5] Updating package list...${NC}"
sudo NEEDRESTART_MODE=a apt-get update -qq

# Install Zsh
echo -e "\n${GREEN}[2/5] Installing Zsh...${NC}"
sudo NEEDRESTART_MODE=a apt-get install -y -qq zsh curl wget unzip

# Install Oh My Zsh
echo -e "\n${GREEN}[3/5] Installing Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

# Install Starship (system-wide via sudo)
echo -e "\n${GREEN}[4/5] Installing Starship...${NC}"
curl -sS https://starship.rs/install.sh | sudo sh -s -- -y

# Add Starship to .zshrc if not already there
if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    echo "Starship added to .zshrc"
fi

# Install FiraCode Nerd Font
echo -e "\n${GREEN}[5/5] Installing FiraCode Nerd Font...${NC}"
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
unzip -q -o FiraCode.zip
rm FiraCode.zip
fc-cache -fv > /dev/null 2>&1

# Change default shell to Zsh
echo -e "\n${YELLOW}Changing default shell to Zsh...${NC}"
sudo chsh -s "$(which zsh)" "$(whoami)"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"
echo -e "Log out and back in to activate Zsh."
echo -e "Script completed successfully! 🚀\n"
