#!/bin/bash
# 🛡️ OPSEC BROWSER - Main Entry Point
# Detects and launches Brave with privacy configuration

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/core.sh"

log_info "Inicializando OPSEC Browser..."

# Check system
log_info "Verificando sistema..."
ensure_brave

# Show help if no arguments
if [ $# -eq 0 ]; then
    echo ""
    echo "🛡️ OPSEC BROWSER"
    echo ""
    echo "Uso: $0 [--mode MODE] [--profile NAME] [URL]"
    echo ""
    echo "Modos:"
    echo "  --mode normal   Navegación normal" 
    echo "  --mode privacy  Privacy + DNS-HTTPS"
    echo "  --mode tor      TOR (máxima privacidad)"
    echo "  --mode proxy    Proxy configurable"
    echo ""
    echo "Perfiles:"
    echo "  --profile default"
    echo "  --profile banking"
    echo "  --profile work"
    echo ""
    echo "Ejemplos:"
    echo "  $0 --mode tor"
    echo "  $0 --mode privacy https://duckduckgo.com"
    echo ""
    exit 0
fi

# Parse and launch
MODE="normal"
PROFILE="default"
URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

launch_brave "$MODE" "$PROFILE" "$URL"
