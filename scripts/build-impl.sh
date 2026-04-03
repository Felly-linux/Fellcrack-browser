#!/bin/bash
# 🏗️ BUILD IMPLEMENTATION - Sentinel Browser
# Compila Brave con configuración personalizada

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Cargar configuración
if [ -f "$PROJECT_ROOT/scripts/.env.sh" ]; then
    source "$PROJECT_ROOT/scripts/.env.sh"
else
    echo "❌ .env.sh no encontrado. Ejecuta: ./scripts/bootstrap.sh"
    exit 1
fi

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[BUILD]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parsear argumentos
BUILD_TYPE="release"
CLEAN=false
JOBS=$(nproc)

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug) BUILD_TYPE="debug"; shift ;;
        --release) BUILD_TYPE="release"; shift ;;
        --clean) CLEAN=true; shift ;;
        --jobs) JOBS="$2"; shift 2 ;;
        *) log_warn "Argumento desconocido: $1"; shift ;;
    esac
done

log_info "🏗️  Compilando Sentinel Browser [$BUILD_TYPE]"
log_info "Usando $JOBS procesos"

# ============================================================
# 1. VALIDAR ESTRUCTURA
# ============================================================
log_info "📁 Validando estructura..."
if [ ! -d "$BRAVE_SRC/src" ]; then
    log_error "Fuente Brave no encontrada en $BRAVE_SRC/src"
    log_info "Ejecuta primero: ./scripts/bootstrap.sh"
    exit 1
fi

cd "$BRAVE_SRC/src"

# ============================================================
# 2. APLICAR PARCHES PERSONALIZADOS
# ============================================================
if [ -d "$PATCHES_DIR" ] && [ -n "$(find "$PATCHES_DIR" -name "*.patch" -type f)" ]; then
    log_info "🔧 Aplicando parches personalizados..."
    for patch in "$PATCHES_DIR"/*.patch; do
        if [ -f "$patch" ]; then
            log_info "  Aplicando: $(basename "$patch")"
            git apply "$patch" 2>&1 || log_warn "  No se pudo aplicar $(basename "$patch")"
        fi
    done
fi

# ============================================================
# 3. GENERACIÓN GN (crear archivos ninja)
# ============================================================
log_info "🔨 Generando archivos Ninja (GN)..."

OUT_DIR="$BUILD_DIR/out/brave-$BUILD_TYPE"
mkdir -p "$OUT_DIR"

# Preparar args.gn con variables de build
cat > "$OUT_DIR/args.gn" <<EOF
# Sentinel Browser Build Configuration
# Generado: $(date)

# Target
target_os = "linux"
target_cpu = "x64"

# Optimización
is_debug = $([ "$BUILD_TYPE" = "debug" ] && echo "true" || echo "false")
is_official_build = true
symbol_level = $([ "$BUILD_TYPE" = "debug" ] && echo "2" || echo "1")

# Security Features
enable_nacl = false
enable_plugins = false
enable_extensions = true
enable_widevine = false
enable_reporting = false
safe_browsing_mode = 0

# Performance
blink_symbol_level = 0
v8_symbol_level = 0
enable_precompiled_javascript_bundles = $([ "$BUILD_TYPE" = "release" ] && echo "true" || echo "false")

# Crypto & Security
enable_socks5 = true
enable_brave_fingerprint_protection = true

# Misc
use_sysroot = false
use_custom_libcxx = true
EOF

log_info "  args.gn: $OUT_DIR/args.gn"

# Correr gn gen
gn gen "$OUT_DIR" 2>&1 | tee -a "$PROJECT_ROOT/logs/gn-gen.log"

# ============================================================
# 4. LIMPIAR BUILD SI ES NECESARIO
# ============================================================
if [ "$CLEAN" = true ]; then
    log_info "🧹 Limpiando compilación anterior..."
    rm -rf "$OUT_DIR/obj" "$OUT_DIR/gen"
fi

# ============================================================
# 5. COMPILACIÓN
# ============================================================
log_info "⚙️  Compilando ($JOBS jobs, esto puede tomar 1-3 horas)..."
log_warn "💡 Monitorea con: tail -f $PROJECT_ROOT/logs/build.log"

ninja -C "$OUT_DIR" -j "$JOBS" brave 2>&1 | tee -a "$PROJECT_ROOT/logs/build.log"

# ============================================================
# 6. VALIDAR BUILD
# ============================================================
log_info "✅ Validando build..."
if [ -f "$OUT_DIR/brave" ]; then
    BINARY_SIZE=$(du -h "$OUT_DIR/brave" | cut -f1)
    log_info "✓ Binario generado: $OUT_DIR/brave ($BINARY_SIZE)"
else
    log_error "Compilación falló: binario no encontrado"
    exit 1
fi

# ============================================================
# 7. CREAR ENLACE SIMBÓLICO
# ============================================================
ln -sf "$OUT_DIR/brave" "$BUILD_DIR/sentinel-browser" 2>/dev/null || true
log_info "✓ Enlace: $BUILD_DIR/sentinel-browser"

# ============================================================
# 8. RESUMEN FINAL
# ============================================================
log_info "🎉 COMPILACIÓN COMPLETA"
cat <<EOF

═══════════════════════════════════════
  SENTINEL BROWSER - BUILD COMPLETADO
═══════════════════════════════════════

Binario:    $OUT_DIR/brave
Tamaño:     $BINARY_SIZE
Tipo:       $BUILD_TYPE
Timestamp:  $(date)

Ejecutar:
  $OUT_DIR/brave
  
O mediante enlace:
  $BUILD_DIR/sentinel-browser

Próximos pasos:
  1. Probar: $BUILD_DIR/sentinel-browser --version
  2. Crear PKGBUILD para Arch: ./arch/create-pkgbuild.sh
  3. Configurar OPSEC: ./tools/opsec-config.sh

═══════════════════════════════════════
EOF

log_info "📖 Build log: $PROJECT_ROOT/logs/build.log"
