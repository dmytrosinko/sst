#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
#  SST — Linux Release Build Script
#  Uses Qt 6.10.2 installed at ~/Qt/6.10.2/gcc_64
#  CMake & Ninja from ~/Qt/Tools/CMake/bin and ~/Qt/Tools/Ninja
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
QT_ROOT="$HOME/Qt"
QT_VERSION="6.10.2"
QT_KIT="gcc_64"
QT_PREFIX="$QT_ROOT/$QT_VERSION/$QT_KIT"
QT_CMAKE="$QT_ROOT/Tools/CMake/bin"
QT_NINJA="$QT_ROOT/Tools/Ninja"

# Source directory = directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR"
BUILD_DIR="$SRC_DIR/build/linux-release"

# Parse arguments
DO_CLEAN=false
SKIP_DEPS=false
DO_PACKAGE=false

for arg in "$@"; do
    case "$arg" in
        --clean)    DO_CLEAN=true   ;;
        --skip-deps) SKIP_DEPS=true ;;
        --package)  DO_PACKAGE=true ;;
        --help|-h)
            echo "Usage: $0 [--clean] [--skip-deps] [--package]"
            echo "  --clean      Remove build directory before building"
            echo "  --skip-deps  Skip dependency installation check"
            echo "  --package    Run CPack after building"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# Add Qt tools to PATH
export PATH="$QT_CMAKE:$QT_NINJA:$PATH"

# ── Pretty output ─────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         SST — Linux Release Build                       ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GRAY}║  Source  : $SRC_DIR${NC}"
echo -e "${GRAY}║  Qt      : $QT_PREFIX${NC}"
echo -e "${GRAY}║  Build   : $BUILD_DIR${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Install build dependencies ────────────────────────────────────────
if [ "$SKIP_DEPS" = false ]; then
    echo -e "${YELLOW}[1/4] Checking & installing build dependencies...${NC}"

    NEEDED=()

    # Compiler
    if ! dpkg -s g++ >/dev/null 2>&1; then NEEDED+=(g++); fi

    # OpenGL / EGL
    if ! dpkg -s libgl-dev >/dev/null 2>&1;        then NEEDED+=(libgl-dev); fi
    if ! dpkg -s libegl1-mesa-dev >/dev/null 2>&1;  then NEEDED+=(libegl1-mesa-dev); fi

    # XCB / X11 libraries (required by Qt Quick)
    for pkg in libxcb-xinerama0-dev libxcb-cursor-dev libxkbcommon-dev \
               libxcb-keysyms1-dev libxcb-shape0-dev libxcb-icccm4-dev \
               libxcb-render-util0-dev libxcb-xkb-dev libxkbcommon-x11-dev \
               libfontconfig1-dev libfreetype-dev libxcb-randr0-dev \
               libxcb-image0-dev libxcb-sync-dev libxcb-xfixes0-dev; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then NEEDED+=("$pkg"); fi
    done

    if [ ${#NEEDED[@]} -eq 0 ]; then
        echo -e "  ${GREEN}All dependencies are already installed.${NC}"
    else
        echo "  Installing: ${NEEDED[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y -qq "${NEEDED[@]}"
        echo -e "  ${GREEN}Dependencies installed.${NC}"
    fi
else
    echo -e "${GRAY}[1/4] Skipping dependency check (--skip-deps).${NC}"
fi

# ── Step 2: Clean (optional) ─────────────────────────────────────────────────
if [ "$DO_CLEAN" = true ]; then
    echo -e "${YELLOW}[2/4] Cleaning build directory...${NC}"
    rm -rf "$BUILD_DIR"
    echo -e "  ${GREEN}Cleaned.${NC}"
else
    echo -e "${GRAY}[2/4] Skipping clean (pass --clean to force).${NC}"
fi

# ── Step 3: Configure ────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/4] Configuring (CMake + Ninja, Release)...${NC}"

cmake -S "$SRC_DIR" \
      -B "$BUILD_DIR" \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
      -DCMAKE_MAKE_PROGRAM="$QT_NINJA/ninja"

echo -e "  ${GREEN}Configure OK.${NC}"

# ── Step 4: Build ────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Building...${NC}"

cmake --build "$BUILD_DIR" --config Release --parallel

echo -e "  ${GREEN}Build OK.${NC}"

# ── Step 5 (optional): Package ───────────────────────────────────────────────
if [ "$DO_PACKAGE" = true ]; then
    echo -e "${YELLOW}[+] Packaging with CPack...${NC}"
    cd "$BUILD_DIR"
    cpack
    echo -e "  ${GREEN}Package created in $BUILD_DIR/output/${NC}"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Build complete!${NC}"
echo -e "${CYAN}  Binary: $BUILD_DIR/src/app${NC}"
echo ""
