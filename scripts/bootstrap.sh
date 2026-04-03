#!/bin/bash
# 🚀 BOOTSTRAP SCRIPT - Sentinel Browser
# Prepara el entorno completo para compilar Brave customizado

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
SOURCE_DIR="$PROJECT_ROOT/src"
PATCHES_DIR="$PROJECT_ROOT/patches"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================================
# 1. VALIDAR SISTEMA
# ============================================================
log_info "🔍 Validando requisitos del sistema..."

check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "$1 no encontrado"
        return 1
    fi
}

deps_missing=0
for cmd in git gcc g++ ninja python3 gn; do
    if ! check_command "$cmd"; then
        deps_missing=1
    fi
done

if [ $deps_missing -eq 1 ]; then
    log_warn "Instalando dependencias faltantes..."
    if command -v pacman &>/dev/null; then
        sudo pacman -Syu --needed base-devel git ninja python gn
    elif command -v apt &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y build-essential git ninja-build python3 gn
    else
        log_error "Gestor de paquetes no reconocido. Instala: base-devel git ninja python3 gn"
        exit 1
    fi
fi

# ============================================================
# 2. CREAR ESTRUCTURA DE DIRECTORIOS
# ============================================================
log_info "📁 Creando estructura de directorios..."
mkdir -p "$BUILD_DIR"/{out,depot_tools,brave}
mkdir -p "$SOURCE_DIR"/{patches,extensions}
mkdir -p "$PROJECT_ROOT"/{logs,cache}

# ============================================================
# 3. DESCARGAR depot_tools (herramienta de build de Chromium)
# ============================================================
log_info "⬇️  Descargando depot_tools..."
if [ ! -d "$BUILD_DIR/depot_tools" ] || [ -z "$(ls -A "$BUILD_DIR/depot_tools" 2>/dev/null)" ]; then
    cd "$BUILD_DIR"
    git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git 2>&1 | tee -a "$PROJECT_ROOT/logs/bootstrap.log"
else
    log_warn "depot_tools ya existe, saltando..."
fi

# Agregar depot_tools al PATH
export PATH="$BUILD_DIR/depot_tools:$PATH"
echo "export PATH=\"$BUILD_DIR/depot_tools:\$PATH\"" >> ~/.bashrc

log_info "✓ depot_tools configurado"

# ============================================================
# 4. PREPARAR GIT PARA CHECKOUT ENORME
# ============================================================
log_info "⚙️  Configurando Git para checkout grande..."
git config --global core.deltaBaseCacheLimit 2g
git config --global core.checkStat "minimal"
git config --global fetch.prune true

# ============================================================
# 5. CREAR DIRECTORIO DE TRABAJO BRAVE
# ============================================================
log_info "🏗️  Configurando workspace Brave..."
BRAVE_SRC="$BUILD_DIR/brave/build"
mkdir -p "$BRAVE_SRC"
cd "$BRAVE_SRC"

# ============================================================
# 6. INICIALIZAR SYNC (descarga fuente de Brave)
# ============================================================
log_info "📥 Sincronizando fuente de Brave (~80GB, esto toma ~2 horas)..."
log_warn "💡 Este proceso es LARGO. Puedes monitorear con: tail -f $PROJECT_ROOT/logs/sync.log"

if [ ! -f "$BRAVE_SRC/.gclient" ]; then
    echo "Creando .gclient..."
    cat > "$BRAVE_SRC/.gclient" <<'EOF'
solutions = [
  {
    "managed": False,
    "name": "src/brave",
    "url": "https://github.com/brave/brave-browser.git",
    "custom_deps": {},
    "custom_vars": {},
  },
  {
    "managed": False,
    "name": "src",
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "custom_deps": {},
    "custom_vars": {},
  },
]
target_os = ["linux"]
target_cpu = ["x64"]
EOF
    
    gclient sync --with_branch_heads 2>&1 | tee -a "$PROJECT_ROOT/logs/sync.log"
else
    log_warn "Workspace Brave ya existe"
fi

# ============================================================
# 7. CREAR SCRIPTS DE CONFIGURACIÓN
# ============================================================
log_info "📝 Generando scripts de configuración..."

cat > "$PROJECT_ROOT/scripts/build.sh" <<'EOF'
#!/bin/bash
# Build script para Sentinel Browser
source "$PROJECT_ROOT/scripts/.env.sh" 2>/dev/null || true
exec "$PROJECT_ROOT/scripts/build-impl.sh" "$@"
EOF

cat > "$PROJECT_ROOT/scripts/.env.sh" <<EOF
export BUILD_DIR="$BUILD_DIR"
export SOURCE_DIR="$SOURCE_DIR"
export PATCHES_DIR="$PATCHES_DIR"
export PROJECT_ROOT="$PROJECT_ROOT"
export PATH="$BUILD_DIR/depot_tools:\$PATH"
export BRAVE_SRC="$BRAVE_SRC"
EOF

chmod +x "$PROJECT_ROOT/scripts/build.sh"

# ============================================================
# 8. CREAR ARCHIVO DE CONFIGURACIÓN GN
# ============================================================
log_info "⚙️  Creando archivo de build GN..."

cat > "$BRAVE_SRC/src/brave/args.gn" <<'EOF'
# 🛡️ SENTINEL BROWSER - GN Build Args

# Arch base
target_os = "linux"
target_cpu = "x64"

# Compilación optimizada
is_debug = false
is_official_build = true
symbol_level = 1

# Security & Privacy
enable_nacl = false
enable_plugins = false
enable_extensions = true
enable_widevine = false

# Deshabilitar telemetría
enable_reporting = false
safe_browsing_mode = 0

# Performance
blink_symbol_level = 0
v8_symbol_level = 0

# TOR & proxy support
enable_socks5 = true

# Anti-fingerprinting (parcialmente nativo en Brave)
enable_brave_fingerprint_protection = true
EOF

log_info "✓ args.gn creado en: $BRAVE_SRC/src/brave/args.gn"

# ============================================================
# 9. CREAR ESTRUCTURA DE PARCHES
# ============================================================
log_info "📋 Preparando directorio de parches..."

cat > "$PATCHES_DIR/README.md" <<'EOF'
# Parches Personalizados para Sentinel Browser

Los parches aquí deben aplicarse al código fuente de Brave después del sync.

## Formato:
- Cada parche es un archivo .patch
- Nombre: `NNN-description.patch` (ej: 001-disable-update-check.patch)

## Aplicación:
```bash
cd src/brave
git apply ../../patches/*.patch
```
EOF

# ============================================================
# 10. CREAR ENLACE DE DESARROLLO
# ============================================================
log_info "🔗 Creando enlace de desarrollo..."
ln -sf "$BRAVE_SRC/src/brave" "$SOURCE_DIR/brave" 2>/dev/null || true

# ============================================================
# 11. GENERAR RESUMEN Y PRÓXIMOS PASOS
# ============================================================
log_info "✅ BOOTSTRAP COMPLETADO"
cat > "$PROJECT_ROOT/.bootstrap-summary" <<EOF
=== SENTINEL BROWSER BOOTSTRAP ===
Completado: $(date)

Directorios:
- Fuente Brave: $BRAVE_SRC/src
- Build: $BUILD_DIR/out
- Parches: $PATCHES_DIR

Próximos pasos:
1. Esperar sync de Brave (monitor: tail -f $PROJECT_ROOT/logs/sync.log)
2. Aplicar parches: cd $BRAVE_SRC/src/brave && git apply ../../patches/*.patch
3. Compilar: $PROJECT_ROOT/scripts/build.sh --release
4. Ejecutar: $BUILD_DIR/out/brave/brave

PATH añadido a ~/.bashrc:
export PATH="$BUILD_DIR/depot_tools:\$PATH"

Recuerda hacer: source ~/.bashrc
EOF

cat "$PROJECT_ROOT/.bootstrap-summary"

log_info "📖 Resumen guardado en: $PROJECT_ROOT/.bootstrap-summary"
log_info "🚀 Para construir: ./scripts/build.sh --release"
