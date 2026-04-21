#!/bin/bash
# ============================================================
# Vivado Project Build Script for Linux
# ============================================================
#
# Usage:
#   ./create_project.sh -design pynq_base_zux
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TCL_SCRIPT="$SCRIPT_DIR/tcl/project.tcl"

DESIGN="pynq_base_zux"
VIVADO_VERSION="2024.2"

show_help() {
    echo "Vivado Project Builder"
    echo "====================="
    echo ""
    echo "Usage: $0 -design <name>"
    echo ""
    echo "Example: $0 -design pynq_base_zux"
    echo ""
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -design)
            DESIGN="$2"
            shift 2
            ;;
        -help|--help)
            show_help
            ;;
        *)
            echo "Unknown: $1"
            show_help
            ;;
    esac
done

CONFIG_FILE="$PROJECT_DIR/designs/$DESIGN/config.tcl"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Design not found: designs/$DESIGN"
    exit 1
fi

echo "========================================"
echo "Vivado Project Builder"
echo "========================================"
echo ""
echo "Design:  $DESIGN"
echo "Config: $CONFIG_FILE"
echo ""

VIVADO_CMD="vivado"

if ! command -v vivado &> /dev/null; then
    VIVADO_CMD="/opt/Xilinx/Vivado/$VIVADO_VERSION/bin/vivado"
    [[ ! -f "$VIVADO_CMD" ]] && VIVADO_CMD="/tools/Xilinx/Vivado/$VIVADO_VERSION/bin/vivado"
fi

echo "Using: $VIVADO_CMD"
echo ""

$VIVADO_CMD -mode tcl -source "$TCL_SCRIPT" -tclargs -design "$DESIGN"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Project creation failed"
    exit 1
fi

echo ""
echo "[SUCCESS] Project created: build/$DESIGN/$DESIGN.xpr"
