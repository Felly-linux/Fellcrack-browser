#!/bin/bash
# 🚀 MAIN SETUP - Sentinel Browser Complete Setup
# Script maestro que configura todo y deja el proyecto listo

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_title() { echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}\n${BLUE}║${NC} $1\n${BLUE}╚════════════════════════════════════════╝${NC}"; }
log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# ============================================================
# HACER TODOS LOS SCRIPTS EJECUTABLES
# ============================================================
log_title "🔐 Configurando permisos"

chmod +x "$SCRIPTS_DIR"/*.sh "$PROJECT_ROOT/tools"/*.sh "$PROJECT_ROOT/arch"/*.sh 2>/dev/null || true
log_info "Scripts compilables configurados"

# ============================================================
# MOSTRAR MENÚ
# ============================================================
show_menu() {
    cat <<EOF

${BLUE}╔═══════════════════════════════════════════════════════╗${NC}
${BLUE}║   🛡️  SENTINEL BROWSER - PROYECTO COMPLETO  🛡️      ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════╝${NC}

${GREEN}FASE 1 - Bootstrap (necesario primero):${NC}
  1) ./scripts/bootstrap.sh
     → Descarga Brave, configura depot_tools, prepara build

${GREEN}FASE 2 - Build & Compilación:${NC}
  2) ./scripts/build.sh --release
     → Compila Sentinel Browser optimizado (1-3 horas)

${GREEN}FASE 3 - Configuración OPSEC:${NC}
  3) ./scripts/opsec-config.sh
     → Genera configuración de privacidad, detección TOR/VPN

${GREEN}FASE 4 - Instalar herramientas TOR:${NC}
  4) ./scripts/install-tor-tools.sh
     → Circuit switcher, IP checker, herramientas TOR

${GREEN}FASE 5 - Ejecutar Sentinel:${NC}
  5) ./scripts/sentinel
     → Lanza el navegador con opciones OPSEC

${GREEN}FASE 6 - Arch Linux:${NC}
  6) cd arch && makepkg -si
     → Compila PKGBUILD para Arch (necesita bootstrap primero)

${YELLOW}OPCIONES AVANZADAS:${NC}
  7) Mostrar estructura del proyecto
  8) Validar instalación
  9) Ver logs de build
  0) Salir

${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

# ============================================================
# FUNCIONES AUXILIARES
# ============================================================
show_structure() {
    echo -e "${BLUE}📁 Estructura del Proyecto:${NC}\n"
    tree -L 2 "$PROJECT_ROOT" --dirsfirst 2>/dev/null || find "$PROJECT_ROOT" -maxdepth 2 -type d | sort
}

validate_install() {
    echo -e "${BLUE}🔍 Validando instalación...${NC}\n"
    
    # Verificar estructura
    required_dirs=("scripts" "config" "patches" "src" "tools" "arch")
    for dir in "${required_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            log_info "Directorio: $dir"
        else
            log_warn "Directorio faltante: $dir"
        fi
    done
    
    # Verificar scripts principales
    required_scripts=(
        "scripts/bootstrap.sh"
        "scripts/build-impl.sh"
        "scripts/opsec-config.sh"
        "scripts/sentinel"
    )
    
    echo ""
    for script in "${required_scripts[@]}"; do
        if [ -x "$PROJECT_ROOT/$script" ]; then
            log_info "Script ejecutable: $script"
        else
            log_warn "Script no ejecutable: $script"
        fi
    done
}

view_logs() {
    echo -e "${BLUE}📋 Últimas líneas de logs:${NC}\n"
    for log in "$PROJECT_ROOT"/logs/*.log; do
        if [ -f "$log" ]; then
            echo "--- $(basename "$log") ---"
            tail -20 "$log"
            echo ""
        fi
    done
}

# ============================================================
# MAIN LOOP
# ============================================================
while true; do
    show_menu
    read -p "Selecciona una opción [0-9]: " choice
    
    case $choice in
        1)
            log_title "🚀 Ejecutando Bootstrap"
            "$SCRIPTS_DIR/bootstrap.sh"
            ;;
        2)
            log_title "🏗️  Compilando Sentinel Browser"
            "$SCRIPTS_DIR/build.sh" --release --jobs $(nproc)
            ;;
        3)
            log_title "⚙️  Configurando OPSEC"
            "$SCRIPTS_DIR/opsec-config.sh"
            ;;
        4)
            log_title "🧅 Instalando herramientas TOR"
            "$SCRIPTS_DIR/install-tor-tools.sh"
            ;;
        5)
            log_title "🚀 Lanzando Sentinel Browser"
            read -p "Argumentos extras (ej: --mode opsec): " extra_args
            "$SCRIPTS_DIR/sentinel" $extra_args
            ;;
        6)
            log_title "📦 Creando paquete Arch"
            cd "$PROJECT_ROOT/arch"
            if command -v makepkg &>/dev/null; then
                makepkg -s
            else
                log_warn "makepkg no encontrado. Necesitas Arch Linux"
            fi
            cd "$PROJECT_ROOT"
            ;;
        7)
            show_structure
            ;;
        8)
            validate_install
            ;;
        9)
            view_logs
            ;;
        0)
            log_info "¡Hasta pronto!"
            exit 0
            ;;
        *)
            log_warn "Opción no reconocida"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
done
