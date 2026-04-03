#!/bin/bash
# 🛡️ OPSEC BROWSER - Auto-Setup
# One-command installation and configuration

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🛡️  OPSEC BROWSER - SETUP 🛡️     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Detect package manager
detect_pm() {
    if command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v yay &>/dev/null; then
        echo "yay"
    elif command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

PM=$(detect_pm)

if [ "$PM" = "unknown" ]; then
    echo -e "${RED}✗ No package manager found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Detected: $PM${NC}"
echo ""

# Install Brave
echo -e "${YELLOW}Installing Brave...${NC}"
if [ "$PM" = "pacman" ]; then
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm brave-browser
elif [ "$PM" = "yay" ]; then
    yay -S --noconfirm brave-browser
elif [ "$PM" = "apt" ]; then
    sudo apt-get update
    sudo apt-get install -y brave-browser
elif [ "$PM" = "dnf" ]; then
    sudo dnf install -y brave
fi
echo -e "${GREEN}✓ Brave installed$(brave --version 2>/dev/null | awk '{print " ("$NF")"}')"${NC}
echo ""

# Install TOR
echo -e "${YELLOW}Installing TOR...${NC}"
if [ "$PM" = "pacman" ]; then
    sudo pacman -S --noconfirm tor
elif [ "$PM" = "yay" ]; then
    yay -S --noconfirm tor
elif [ "$PM" = "apt" ]; then
    sudo apt-get install -y tor
elif [ "$PM" = "dnf" ]; then
    sudo dnf install -y tor
fi

# Enable TOR service
if command -v systemctl &>/dev/null; then
    sudo systemctl enable tor 2>/dev/null || true
    sudo systemctl start tor 2>/dev/null || true
fi

echo -e "${GREEN}✓ TOR installed${NC}"
echo ""

# Create symlink
echo -e "${YELLOW}Creating symlink...${NC}"
sudo ln -sf "$PROJECT_ROOT/bin/opsec-browser" /usr/local/bin/opsec-browser
echo -e "${GREEN}✓ Available as: opsec-browser${NC}"
echo ""

# Setup directories
echo -e "${YELLOW}Setting up directories...${NC}"
mkdir -p ~/.config/opsec-browser/{default,banking,work,personal}
mkdir -p ~/.cache/opsec-browser
echo -e "${GREEN}✓ Profiles created${NC}"
echo ""

# Show status
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ INSTALLATION COMPLETE${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo "Available commands:"
echo "  opsec-browser --normal              Normal mode"
echo "  opsec-browser --privacy             Privacy mode (DNS-HTTPS)"
echo "  opsec-browser --tor                 TOR mode"
echo "  opsec-browser --profile banking     Isolated profile"
echo ""
echo "Examples:"
echo "  opsec-browser --tor https://example.onion"
echo "  opsec-browser --privacy https://duckduckgo.com"
echo "  opsec-browser --profile work https://github.com"
echo ""
