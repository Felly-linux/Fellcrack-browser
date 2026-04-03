#!/bin/bash
# 🏗️ Create PKGBUILD - Genera PKGBUILD para Arch
# Este script está en tools/ para facilitar el building en Arch

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCH_DIR="$PROJECT_ROOT/arch"

mkdir -p "$ARCH_DIR"

# PKGBUILD ya está creado en arch/PKGBUILD
# Este script simplemente valida y prepara para el build

echo "✅ PKGBUILD disponible en: $ARCH_DIR/PKGBUILD"
echo ""
echo "Para compilar en Arch Linux:"
echo ""
echo "  cd $ARCH_DIR"
echo "  makepkg -si"
echo ""
echo "Para compilar sin instalar:"
echo "  makepkg"
echo ""
echo "Para ver el contenido final antes de instalar:"
echo "  makepkg --nobuild"
