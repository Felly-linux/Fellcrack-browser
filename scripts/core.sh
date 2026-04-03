#!/bin/bash
# 🛡️ OPSEC BROWSER - Core Functions
# Base functions for Brave wrapper

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"
CACHE_DIR="${HOME}/.cache/opsec-browser"
PROFILE_DIR="${HOME}/.config/opsec-browser"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# ============================================================
# Detect and install Brave
# ============================================================
ensure_brave() {
    if command -v brave &>/dev/null; then
        log_info "Brave detectado: $(brave --version 2>/dev/null | head -1)"
        return 0
    fi
    
    log_warn "Brave no encontrado. Instalando..."
    
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm brave-browser
        log_info "Brave instalado vía pacman"
    elif command -v yay &>/dev/null; then
        yay -S --noconfirm brave-browser
        log_info "Brave instalado vía yay"
    elif command -v apt &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y brave-browser
        log_info "Brave instalado vía apt"
    else
        log_error "No package manager found. Install Brave manually."
    fi
}

# ============================================================
# Ensure TOR is installed and running
# ============================================================
ensure_tor() {
    if ! command -v tor &>/dev/null; then
        log_warn "TOR no encontrado. Instalando..."
        
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm tor
        elif command -v apt &>/dev/null; then
            sudo apt-get install -y tor
        fi
    fi
    
    # Start TOR if not running
    if ! nc -z localhost 9050 2>/dev/null; then
        log_warn "Iniciando TOR..."
        sudo systemctl start tor 2>/dev/null || tor &
        sleep 3  # Wait for TOR to start
        
        if nc -z localhost 9050 2>/dev/null; then
            log_info "TOR iniciado en puerto 9050"
        else
            log_error "TOR no pudo iniciarse"
        fi
    else
        log_info "TOR ya está corriendo (puerto 9050)"
    fi
}

# ============================================================
# Build privacy flags for Brave
# ============================================================
get_privacy_flags() {
    local mode="$1"
    local flags=""
    
    # Base privacy flags
    flags="--disable-component-extensions-with-background-pages"
    flags="$flags --disable-default-apps"
    flags="$flags --disable-extensions"
    flags="$flags --disable-background-networking"
    flags="$flags --disable-client-side-phishing-detection"
    flags="$flags --disable-component-update"
    flags="$flags --disable-sync"
    flags="$flags --no-first-run"
    flags="$flags --no-default-browser-check"
    flags="$flags --disable-default-browser-agent"
    
    # WebRTC leak prevention
    flags="$flags --disable-device-discovery-notifications"
    
    case "$mode" in
        privacy)
            # DNS-HTTPS + anti-fingerprinting
            flags="$flags --enable-strict-mixed-content-checking"
            flags="$flags --block-all-mixed-content"
            ;;
        opsec)
            # Everything hardened
            flags="$flags --disable-plugins"
            flags="$flags --enable-strict-mixed-content-checking"
            flags="$flags --block-all-mixed-content"
            flags="$flags --no-service-autorun"
            ;;
    esac
    
    echo "$flags"
}

# ============================================================
# Setup profile directory
# ============================================================
setup_profile() {
    local profile_name="${1:-default}"
    local profile_path="$PROFILE_DIR/$profile_name"
    
    mkdir -p "$profile_path"
    echo "$profile_path"
}

# ============================================================
# Get Brave binary path
# ============================================================
get_brave_binary() {
    if command -v brave &>/dev/null; then
        command -v brave
    elif [ -f "/usr/bin/brave" ]; then
        echo "/usr/bin/brave"
    elif [ -f "/usr/bin/brave-browser" ]; then
        echo "/usr/bin/brave-browser"  
    else
        log_error "Brave binary not found"
    fi
}

# ============================================================
# Launch Brave with options
# ============================================================
launch_brave() {
    local mode="$1"
    local profile="${2:-default}"
    local url="${3:-}"
    
    ensure_brave
    
    local brave_bin=$(get_brave_binary)
    local profile_path=$(setup_profile "$profile")
    local flags=$(get_privacy_flags "$mode")
    
    # Setup proxy if TOR mode
    if [ "$mode" = "opsec" ] || [ "$mode" = "tor" ]; then
        ensure_tor
        flags="$flags --proxy-server=socks5://127.0.0.1:9050"
        log_info "Modo TOR: proxy SOCKS5://127.0.0.1:9050"
    fi
    
    local cmd="$brave_bin --user-data-dir=$profile_path $flags"
    
    if [ -n "$url" ]; then
        cmd="$cmd '$url'"
    fi
    
    log_info "Lanzando Brave ($mode mode)"
    eval "$cmd"
}

# Export functions
export -f ensure_brave ensure_tor get_privacy_flags setup_profile get_brave_binary launch_brave
export -f log_info log_warn log_error
export PROJECT_ROOT CONFIG_DIR CACHE_DIR PROFILE_DIR
