#!/bin/bash
# 🚀 QUICK START - Sentinel Browser
# Script simple para comenzar rápidamente

echo "🛡️  BIENVENIDO A SENTINEL BROWSER"
echo ""
echo "Iniciando setup rápido..."
echo ""

# Paso 1: Validar dependencias
echo "✓ Fase 1: Validando dependencias..."

missing_deps=0
for cmd in git gcc ninja python3 gn; do
    if ! command -v $cmd &>/dev/null; then
        echo "  ❌ $cmd no encontrado"
        missing_deps=1
    else
        echo "  ✓ $cmd OK"
    fi
done

if [ $missing_deps -eq 1 ]; then
    echo ""
    echo "📦 Instalando dependencias..."
    
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed base-devel git ninja python gn
    elif command -v apt &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y build-essential git ninja-build python3 gn
    fi
fi

cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"

# Paso 2: Bootstrap
echo ""
echo "✓ Fase 2: Bootstrap (descargando Brave ~80GB, 2 horas)..."
echo ""
echo "   Ejecutando: ./scripts/bootstrap.sh"
echo ""

bash ./scripts/bootstrap.sh

# Paso 3: Build
echo ""
echo "✓ Fase 3: Build (compilando, 1-3 horas)..."
echo ""
echo "   Ejecutando: ./scripts/build.sh --release"
echo ""

bash ./scripts/build.sh --release

# Paso 4: OPSEC
echo ""
echo "✓ Fase 4: Configuración OPSEC..."
echo ""

bash ./scripts/opsec-config.sh

# Resumen
echo ""
echo "╔════════════════════════════════════════╗"
echo "║  ✅ SENTINEL BROWSER CONFIGURADO       ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Para ejecutar:"
echo "  ./scripts/sentinel                 # Normal"
echo "  ./scripts/sentinel --mode opsec    # OPSEC mode"
echo "  ./scripts/sentinel --tor           # Force TOR"
echo ""
echo "Menú completo:"
echo "  bash $PROJECT_ROOT/setup.sh"
echo ""
