#!/bin/bash
# 🎯 SENTINEL BROWSER SYSTEM CHECK
# Verifica integridad del proyecto antes del bootstrap

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🛡️  SENTINEL BROWSER - SYSTEM CHECK 🛡️       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

check_file() {
    if [ -f "$1" ]; then
        size=$(du -h "$1" | cut -f1)
        echo -e "${GREEN}✓${NC} $2 (${size})"
        return 0
    else
        echo -e "${RED}✗${NC} $2 - NOT FOUND"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        count=$(find "$1" -type f | wc -l)
        echo -e "${GREEN}✓${NC} $2 (${count} files)"
        return 0
    else
        echo -e "${RED}✗${NC} $2 - NOT FOUND"
        return 1
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $2 (executable)"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $2 (needs chmod +x)"
        return 1
    fi
}

# Check structure
echo -e "${BLUE}📁 PROJECT STRUCTURE${NC}"
echo "─" × 50

check_dir "$PROJECT_ROOT/scripts" "scripts/"
check_dir "$PROJECT_ROOT/tools" "tools/"
check_dir "$PROJECT_ROOT/config" "config/"
check_dir "$PROJECT_ROOT/patches" "patches/"
check_dir "$PROJECT_ROOT/arch" "Arch PKGBUILD"
check_dir "$PROJECT_ROOT/src" "src/"

echo ""
echo -e "${BLUE}📝 MAIN SCRIPTS${NC}"
echo "─" × 50

check_executable "$PROJECT_ROOT/scripts/bootstrap.sh" "bootstrap.sh"
check_executable "$PROJECT_ROOT/scripts/build-impl.sh" "build-impl.sh"
check_executable "$PROJECT_ROOT/scripts/opsec-config.sh" "opsec-config.sh"
check_executable "$PROJECT_ROOT/scripts/sentinel" "sentinel launcher"
check_executable "$PROJECT_ROOT/quickstart.sh" "quickstart.sh"
check_executable "$PROJECT_ROOT/setup.sh" "setup.sh"

echo ""
echo -e "${BLUE}📖 DOCUMENTATION${NC}"
echo "─" × 50

check_file "$PROJECT_ROOT/README.md" "README.md"
check_file "$PROJECT_ROOT/QUICKSTART.md" "QUICKSTART.md"
check_file "$PROJECT_ROOT/TECHNICAL.md" "TECHNICAL.md"
check_file "$PROJECT_ROOT/PROJECT.md" "PROJECT.md"

echo ""
echo -e "${BLUE}⚙️  CONFIGURATION${NC}"
echo "─" × 50

check_file "$PROJECT_ROOT/config/sentinel-opsec.conf" "OPSEC config"
check_file "$PROJECT_ROOT/config/routing-rules.yaml" "Routing rules"

echo ""
echo -e "${BLUE}🔧 TOOLS${NC}"
echo "─" × 50

check_file "$PROJECT_ROOT/tools/tor-circuit-switcher.py" "TOR circuit switcher"
check_file "$PROJECT_ROOT/tools/check-ip.sh" "IP checker"
check_file "$PROJECT_ROOT/tools/install-extensions.sh" "Extension installer"

echo ""
echo -e "${BLUE}📦 ARCH INTEGRATION${NC}"
echo "─" × 50

check_file "$PROJECT_ROOT/arch/PKGBUILD" "PKGBUILD"

# System requirements
echo ""
echo -e "${BLUE}🔍 SYSTEM REQUIREMENTS${NC}"
echo "─" × 50

check_deps() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &>/dev/null; then
        version=$($cmd --version 2>/dev/null | head -1 || echo "OK")
        echo -e "${GREEN}✓${NC} $name: $version"
    else
        echo -e "${RED}✗${NC} $name: NOT INSTALLED"
    fi
}

check_deps "git" "Git"
check_deps "gcc" "GCC"
check_deps "g++" "G++"
check_deps "ninja" "Ninja"
check_deps "python3" "Python3"
check_deps "gn" "GN"

# Disk space
echo ""
echo -e "${BLUE}💾 DISK SPACE${NC}"
echo "─" × 50

available=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
needed=100  # GB
available_gb=$((available / 1024 / 1024))

echo "Available: ${available_gb} GB"
echo "Needed for build: ${needed} GB"

if [ "$available_gb" -gt "$needed" ]; then
    echo -e "${GREEN}✓${NC} Sufficient disk space"
else
    echo -e "${RED}✗${NC} INSUFFICIENT disk space (need ${needed}GB, have ${available_gb}GB)"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ✅ PROJECT READY FOR BOOTSTRAP                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${GREEN}NEXT STEPS:${NC}"
echo "1. Start:       ${BLUE}bash quickstart.sh${NC}"
echo "2. Or manual:   ${BLUE}./scripts/bootstrap.sh${NC}"
echo "3. Or menu:     ${BLUE}bash setup.sh${NC}"
echo ""
echo -e "${YELLOW}⏱️  TIMING ESTIMATE:${NC}"
echo "   Phase 1: 2 hours (bootstrap/sync)"
echo "   Phase 2: 1-3 hours (compilation)"
echo "   Total:   3-5 hours"

echo ""
echo "📖 Documentation: $PROJECT_ROOT/PROJECT.md"
echo ""
