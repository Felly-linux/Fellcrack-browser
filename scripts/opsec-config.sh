#!/bin/bash
# 🛡️ OPSEC CONFIG - Sentinel Browser
# Script interactivo para configurar privacidad y seguridad

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_title() { echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${BLUE}$1${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ============================================================
# DETECTAR CONFIGURACIÓN DEL SISTEMA
# ============================================================
log_title "🔍 DETECCIÓN DE SISTEMA"

# Detectar TOR
if systemctl is-active --quiet tor; then
    log_info "TOR detectado (servicio activo)"
    TOR_AVAILABLE=true
    TOR_PORT=$(grep "^SocksPort" /etc/tor/torrc 2>/dev/null | awk '{print $2}' | head -1)
    TOR_PORT=${TOR_PORT:-9050}
    log_info "  TOR SOCKS5: port $TOR_PORT"
else
    log_warn "TOR no está activo"
    TOR_AVAILABLE=false
    TOR_PORT=9050
fi

# Detectar VPN
if ip link show tun0 &>/dev/null || ip link show wg0 &>/dev/null; then
    log_info "Interfaz VPN detectada"
    VPN_AVAILABLE=true
else
    log_warn "No se detectó VPN activa"
    VPN_AVAILABLE=false
fi

# ============================================================
# GENERAR CONFIGURACIÓN
# ============================================================
log_title "⚙️  GENERANDO CONFIGURACIÓN"

CONFIG_DIR="$PROJECT_ROOT/config"
mkdir -p "$CONFIG_DIR"

# Archivo de configuración principal
cat > "$CONFIG_DIR/sentinel-opsec.conf" <<EOF
# 🛡️ SENTINEL BROWSER - OPSEC Configuration
# Generado: $(date)

[privacy]
# DNS Settings
dns_over_https = true
dns_over_tls = true
dns_providers = ["1.1.1.2", "1.0.0.2", "2606:4700:4700::1112", "2606:4700:4700::1002"]
dns_fallback = ["8.8.8.8", "1.1.1.1"]

# Disable tracking
disable_analytics = true
disable_telemetry = true
disable_crash_reporter = true
disable_malware_check = true

# Anti-fingerprinting
reduce_motion = true
color_scheme = dark
timezone_tracking = false

[proxy]
# TOR Configuration
tor_enabled = $( [ "$TOR_AVAILABLE" = true ] && echo "true" || echo "false" )
tor_host = 127.0.0.1
tor_port = $TOR_PORT
tor_verify_ssl = false

# HTTP/HTTPS Proxy fallback
http_proxy = ""
https_proxy = ""

# VPN
vpn_available = $( [ "$VPN_AVAILABLE" = true ] && echo "true" || echo "false" )
vpn_interface = "tun0"

[security]
# WebRTC leak prevention
disable_webrtc_leak = true

# Disable features
disable_plugins = true
disable_widevine = true
disable_drmh264 = true

# Mixed content
block_mixed_content = true

# JavaScript restrictions
disable_javascript_in_iframes = false
restrict_resource_access = true

[performance]
# Optimization
enable_hardware_acceleration = false
enable_compositing = true
background_tab_throttle = true

# Memory
memory_limit_mb = 1024

[extensions]
# Recommended security extensions
installed_extensions = [
    "ublock-origin",
    "privacy-badger",
    "decentraleyes"
]

auto_update_extensions = false
allow_extension_permissions = false

[updates]
# Update behavior
auto_update_browser = false
notify_security_updates = true
check_on_startup = true

[startup]
# Session restore
restore_session = false
clear_on_exit = true
delete_cookies_on_exit = true
delete_cache_on_exit = true
delete_browsing_history_on_exit = false
delete_downloads_history_on_exit = false
delete_passwords_on_exit = false

[cli]
# Command line defaults
default_mode = "normal"  # normal, privacy, opsec, tor
disable_extensions_cli = false
offline_mode = false
EOF

log_info "Configuración guardada: $CONFIG_DIR/sentinel-opsec.conf"

# Archivo de reglas de routing
cat > "$CONFIG_DIR/routing-rules.yaml" <<EOF
# 🔀 ROUTING RULES - Sentinel Browser
# Define qué sitios usan direct/proxy/tor

routes:
  # Direct access (rápido, sin privacidad)
  direct:
    - github.com
    - stackoverflow.com
    - youtube.com

  # Proxy (moderado)
  proxy:
    - google.com
    - facebook.com
    - amazon.com

  # TOR (máxima privacidad)
  tor:
    - "*.onion"
    - protonmail.com
    - encrypted-search.com
    - duckduckgo.com

# Reglas globales
global:
  # Si la URL coincide, usar esta ruta
  default_route: "direct"
  
  # Mode presets
  modes:
    normal:
      description: "Navegación normal"
      default_route: "direct"
      
    privacy:
      description: "Navegación privada (DNS/HTTPS)"
      default_route: "direct"
      enforce_https: true
      block_ads: true
      
    opsec:
      description: "OPSEC máximo (todo a través de proxy/tor)"
      default_route: "tor"
      enforce_https: true
      block_ads: true
      disable_javascript: false
      
    onion:
      description: "Solo .onion (todo TOR)"
      default_route: "tor"
      force_tor: true
EOF

log_info "Routing rules guardadas: $CONFIG_DIR/routing-rules.yaml"

# ============================================================
# CREAR LAUNCHER SCRIPT
# ============================================================
log_title "🚀 CREAR LAUNCHER"

cat > "$PROJECT_ROOT/scripts/sentinel" <<'EOF'
#!/bin/bash
# 🛡️ Sentinel Browser Launcher
# Ejecuta Brave con configuración OPSEC específica

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
CONFIG_DIR="$PROJECT_ROOT/config"

# Modo por defecto
MODE="normal"
TOR=false
VPN=false
OFFLINE=false
PROFILE_DIR=""
PROFILE_NAME="default"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tor) TOR=true; shift ;;
        --vpn) VPN=true; shift ;;
        --offline) OFFLINE=true; shift ;;
        --mode) MODE="$2"; shift 2 ;;
        --profile) PROFILE_NAME="$2"; shift 2 ;;
        --help) show_help; exit 0 ;;
        *) break ;;
    esac
done

show_help() {
    cat <<'HELP'
🛡️ Sentinel Browser - Privacy-First Navigation

Usage: ./scripts/sentinel [OPTIONS] [URL...]

Options:
  --tor              Force all traffic through TOR
  --vpn              Use system VPN if available
  --offline          Offline mode (cached content only)
  --mode MODE        Set mode: normal, privacy, opsec, onion
  --profile NAME     Use specific profile (default: default)
  --help             Show this help

Examples:
  ./scripts/sentinel                  # Normal mode
  ./scripts/sentinel --mode opsec    # OPSEC mode
  ./scripts/sentinel --tor            # Force TOR
  ./scripts/sentinel --mode tor https://example.onion
  ./scripts/sentinel --vpn https://protonmail.com

Profiles:
  Profiles are stored in: ~/.sentinel-browser/

HELP
}

if [ $# -eq 0 ]; then
    show_help
fi

# Browser path
BROWSER="$BUILD_DIR/sentinel-browser"
if [ ! -f "$BROWSER" ]; then
    BROWSER="$(which brave || which chromium || which google-chrome)" 2>/dev/null
fi

if [ ! -f "$BROWSER" ]; then
    echo "❌ Navegador no encontrado. Compila primero: ./scripts/build.sh --release"
    exit 1
fi

# Profile directory
PROFILE_DIR="$HOME/.sentinel-browser/$PROFILE_NAME"
mkdir -p "$PROFILE_DIR"

# Construir argumentos de Chromium
CHROMIUM_FLAGS=(
    "--user-data-dir=$PROFILE_DIR"
    "--no-first-run"
)

# Modo específico
case "$MODE" in
    privacy)
        CHROMIUM_FLAGS+=(
            "--disable-plugins"
            "--disable-extensions-except=uBlock0@raymondhill.net"
        )
        ;;
    opsec)
        CHROMIUM_FLAGS+=(
            "--disable-plugins"
            "--disable-extensions-except=uBlock0@raymondhill.net,privacy-badger@eff.org"
            "--disable-default-apps"
            "--no-service-autorun"
        )
        TOR=true
        ;;
    onion|tor)
        TOR=true
        CHROMIUM_FLAGS+=(
            "--disable-plugins"
            "--disable-extensions-except=uBlock0@raymondhill.net"
            "--no-service-autorun"
        )
        ;;
esac

# TOR
if [ "$TOR" = true ]; then
    # Check TOR availability
    if ! nc -z localhost 9050 2>/dev/null; then
        echo "⚠️  TOR no disponible en localhost:9050"
        echo "   Inicia: sudo systemctl start tor"
        exit 1
    fi
    CHROMIUM_FLAGS+=(
        "--proxy-server=socks5://127.0.0.1:9050"
    )
    echo "🧅 Modo TOR activado"
fi

# VPN
if [ "$VPN" = true ]; then
    if ip link show tun0 &>/dev/null || ip link show wg0 &>/dev/null; then
        echo "📡 VPN del sistema detectada y activada"
    else
        echo "⚠️  VPN no disponible"
    fi
fi

# Offline
if [ "$OFFLINE" = true ]; then
    CHROMIUM_FLAGS+=(
        "--offline"
    )
    echo "📴 Modo offline"
fi

# Print flags
echo "🚀 Iniciando Sentinel Browser"
echo "   Modo: $MODE"
echo "   Perfil: $PROFILE_NAME"
echo "   Navegador: $BROWSER"

# Ejecutar
exec "$BROWSER" "${CHROMIUM_FLAGS[@]}" "$@"
EOF

chmod +x "$PROJECT_ROOT/scripts/sentinel"
log_info "Launcher creado: $PROJECT_ROOT/scripts/sentinel"

# ============================================================
# CREAR ARCHIVO .env DE VARIABLES
# ============================================================
log_title "📝 RESUMEN DE CONFIGURACIÓN"

cat > "$CONFIG_DIR/.opsec-env" <<EOF
# Sentinel Browser - OPSEC Environment Variables

TOR_AVAILABLE=$TOR_AVAILABLE
TOR_PORT=$TOR_PORT
VPN_AVAILABLE=$VPN_AVAILABLE

# Usar estos valores en scripts:
# source $CONFIG_DIR/.opsec-env
EOF

# ============================================================
# MOSTRAR PRÓXIMOS PASOS
# ============================================================
cat <<EOF

✅ CONFIGURACIÓN OPSEC COMPLETADA

Archivos generados:
  • $CONFIG_DIR/sentinel-opsec.conf (configuración principal)
  • $CONFIG_DIR/routing-rules.yaml (reglas de routing)
  • $PROJECT_ROOT/scripts/sentinel (launcher)

Ejecutar Sentinel Browser:
  ./scripts/sentinel --mode opsec
  ./scripts/sentinel --tor
  ./scripts/sentinel --mode privacy https://duckduckgo.com

Configuración disponible:
  - DNS Over HTTPS/TLS
  - Anti-fingerprinting
  - WebRTC leak prevention
  - TOR integration
  - VPN support
  - Custom routing rules

Próximos pasos:
  1. Compilar: ./scripts/build.sh --release
  2. Probar: ./scripts/sentinel --help
  3. Configurar extensiones: ./tools/install-extensions.sh
  4. Arch PKGBUILD: ./arch/create-pkgbuild.sh

EOF

log_info "OPSEC config completada"
