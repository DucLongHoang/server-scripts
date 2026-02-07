#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Terminal Enhancement Setup Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Update package list
echo -e "${GREEN}[1/5] Updating package list...${NC}"
sudo apt update

# Install Zsh
echo -e "\n${GREEN}[2/5] Installing Zsh...${NC}"
sudo apt install zsh curl wget unzip -y

# Install Oh My Zsh
echo -e "\n${GREEN}[3/5] Installing Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

# Install Starship
echo -e "\n${GREEN}[4/5] Installing Starship...${NC}"
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add Starship to .zshrc if not already there
if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    echo "Starship added to .zshrc"
fi

# Install FiraCode Nerd Font
echo -e "\n${GREEN}[5/5] Installing FiraCode Nerd Font...${NC}"
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"

# Download latest FiraCode Nerd Font
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip

# Extract and cleanup
unzip -q -o FiraCode.zip
rm FiraCode.zip

# Refresh font cache
fc-cache -fv > /dev/null 2>&1

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Change default shell to Zsh
echo -e "${YELLOW}Changing default shell to Zsh...${NC}"
chsh -s $(which zsh)

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  IMPORTANT - Manual Steps Required${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}1. FONT CONFIGURATION:${NC}"
echo -e "   Open your terminal preferences/settings and change the font to:"
echo -e "   ${GREEN}FiraCode Nerd Font Mono${NC}\n"
echo -e "   Location depends on your terminal:"
echo -e "   • GNOME Terminal: Preferences → Profile → Text → Custom font"
echo -e "   • Konsole: Settings → Edit Current Profile → Appearance → Font"
echo -e "   • Alacritty: Edit ~/.config/alacritty/alacritty.yml\n"

echo -e "${YELLOW}2. ACTIVATE ZSH:${NC}"
echo -e "   ${GREEN}Log out and log back in${NC} (or close and reopen SSH session)"
echo -e "   to activate Zsh as your default shell.\n"

echo -e "${YELLOW}3. TEST THE SETUP:${NC}"
echo -e "   After logging back in, run:"
echo -e "   ${GREEN}echo \$SHELL${NC}  # Should show /usr/bin/zsh"
echo -e "   ${GREEN}echo -e \"\\ue0b0 \\u00b1 \\ue0a0 \\u27a6 \\u2718 \\u26a1 \\u2699\"${NC}  # Test icons\n"

echo -e "${BLUE}========================================${NC}\n"
echo -e "Script completed successfully! 🚀"
echo -e "Remember to log out and back in to see the changes.\n"
