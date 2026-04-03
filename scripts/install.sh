#!/bin/bash
# 🛡️ OPSEC BROWSER - Installation Script
# Sets up the system and creates symlinks

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$PROJECT_ROOT/bin"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️ OPSEC BROWSER - INSTALACIÓN${NC}"
echo ""

# Check for package manager
if command -v pacman &>/dev/null; then
    PKG_CMD="pacman"
    PKG_INSTALL="sudo pacman -S --noconfirm"
elif command -v yay &>/dev/null; then
    PKG_CMD="yay"
    PKG_INSTALL="yay -S --noconfirm"
elif command -v apt &>/dev/null; then
    PKG_CMD="apt"
    PKG_INSTALL="sudo apt-get install -y"
else
    echo "❌ No package manager found"
    exit 1
fi

echo "Package manager: $PKG_CMD"
echo ""

# Install Brave if not present
if ! command -v brave &>/dev/null; then
    echo "📦 Instalando Brave..."
    if [ "$PKG_CMD" = "pacman" ]; then
        sudo pacman -S --noconfirm brave-browser
    elif [ "$PKG_CMD" = "apt" ]; then
        $PKG_INSTALL brave-browser
    fi
fi

# Install TOR
if ! command -v tor &>/dev/null; then
    echo "📦 Instalando TOR..."
    if [ "$PKG_CMD" = "pacman" ]; then
        sudo pacman -S --noconfirm tor
    elif [ "$PKG_CMD" = "apt" ]; then
        $PKG_INSTALL tor
    fi
fi

# Create symlink in /usr/local/bin
if [ -f "$BIN_DIR/opsec-browser" ]; then
    echo "🔗 Creando symlink..."
    sudo ln -sf "$BIN_DIR/opsec-browser" /usr/local/bin/opsec-browser
    echo -e "${GREEN}✓${NC} opsec-browser disponible globalmente"
fi

# Setup profile directory
mkdir -p ~/.config/opsec-browser/default
mkdir -p ~/.cache/opsec-browser

echo ""
echo -e "${GREEN}✓ Instalación completada${NC}"
echo ""
echo "Uso:"
echo "  opsec-browser --tor"
echo "  opsec-browser --privacy https://duckduckgo.com"
echo "  opsec-browser --profile banking https://mybank.com"
echo ""
