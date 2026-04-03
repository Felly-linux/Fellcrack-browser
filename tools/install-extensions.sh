#!/bin/bash
# 📦 Install Security Extensions - Sentinel Browser
# Instala extensiones recomendadas para privacidad

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="${HOME}/.sentinel-browser/default"

mkdir -p "$PROFILE_DIR/Extensions"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_title() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${BLUE}$1${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

log_title "📦 INSTALAR EXTENSIONES DE SEGURIDAD"

# Extensiones recomendadas (en Chrome Web Store)
EXTENSIONS=(
    "uBlock Origin:cjpalhdlnbpafiamejdnhcphjbkeiagm"
    "Privacy Badger:pkehgijcmpdhfbdbnglmhebglug0xobo"
    "Decentraleyes:gcbommkclmclpchlhbikncbgkdjohfsm"
    "DuckDuckGo:lecbbbog5ckldpvvbnnnhole2dqjcakp"
    "HTTPS Everywhere:gcbommkclmclpchlhbikncbgkdjohfsm"
)

echo -e "${BLUE}Extensiones recomendadas para Sentinel Browser:${NC}\n"

for ext_info in "${EXTENSIONS[@]}"; do
    IFS=":" read -r name id <<< "$ext_info"
    log_info "$name (ID: $id)"
    echo "  → Visita: https://chrome.google.com/webstore/detail/$id"
done

echo ""
echo -e "${BLUE}Cómo instalar:${NC}"
echo "1. Abre Sentinel Browser"
echo "2. Ve a las URLs anteriores"
echo "3. Haz clic en 'Añadir a Chrome'"
echo "4. Acepta permisos"
echo ""
echo -e "${BLUE}Para instalar programáticamente:${NC}"
echo "Los perfiles se almacenan en: $PROFILE_DIR"
echo "Extensiones en: $PROFILE_DIR/Extensions"
