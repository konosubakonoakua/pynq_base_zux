#!/bin/bash
# ============================================================
# PYNQ-ZUX Project Build Script for Linux
# ============================================================
#
# Usage:
#   ./create_project.sh                    - Use defaults (ZU15, 2024.1)
#   ./create_project.sh -part xczu9eg...  - Specify part
#   ./create_project.sh -version 2021.1   - Specify Vivado version
#   ./create_project.sh -help              - Show help
#
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TCL_SCRIPT="$SCRIPT_DIR/tcl/project.tcl"

VIVADO_VERSION="2024.1"
PART="xczu15eg-ffvb1156-2-i"
PROJECT_NAME="pynq_base_zux"
OUTPUT_DIR="$PROJECT_DIR/build"

show_help() {
    echo ""
    echo "PYNQ-ZUX Project Builder - Help"
    echo "================================="
    echo ""
    echo "Usage:"
    echo "  $0 [options]"
    echo ""
    echo "Options:"
    echo "  -part          FPGA part (default: xczu15eg-ffvb1156-2-i)"
    echo "  -version       Vivado version (default: 2024.1)"
    echo "  -project_name  Project name (default: pynq_base_zux)"
    echo "  -output_dir    Output directory (default: ./build)"
    echo "  -help          Show this help"
    echo ""
    echo "Supported Parts:"
    echo "  xczu15eg-ffvb1156-2-i  (ZU15, default)"
    echo "  xczu9eg-ffvb1156-2-i   (ZU9)"
    echo ""
    echo "Supported Versions:"
    echo "  2024.1, 2024.2, 2023.2, 2023.1, 2022.3, 2022.1, 2021.1"
    echo ""
    echo "Example:"
    echo "  $0 -part xczu9eg-ffvb1156-2-i -version 2022.1"
    echo ""
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -part)
            PART="$2"
            shift 2
            ;;
        -version)
            VIVADO_VERSION="$2"
            shift 2
            ;;
        -project_name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -output_dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -help|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

echo "============================================================"
echo "PYNQ-ZUX Project Builder"
echo "============================================================"
echo ""
echo "Vivado Version: $VIVADO_VERSION"
echo "Part:           $PART"
echo "Project Name:   $PROJECT_NAME"
echo "Output Dir:     $OUTPUT_DIR"
echo ""

VIVADO_CMD="vivado"

if ! command -v vivado &> /dev/null; then
    VIVADO_CMD="/opt/Xilinx/Vivado/$VIVADO_VERSION/bin/vivado"
    if [[ ! -f "$VIVADO_CMD" ]]; then
        VIVADO_CMD="/tools/Xilinx/Vivado/$VIVADO_VERSION/bin/vivado"
    fi
fi

echo "Using Vivado: $VIVADO_CMD"
echo ""

mkdir -p "$OUTPUT_DIR"

echo "Running Vivado to create project..."
echo ""

$VIVADO_CMD -mode tcl -source "$TCL_SCRIPT" -tclargs \
    -part "$PART" \
    -version "$VIVADO_VERSION" \
    -project_name "$PROJECT_NAME" \
    -output_dir "$OUTPUT_DIR"

if [[ $? -ne 0 ]]; then
    echo ""
    echo "[ERROR] Project creation failed!"
    exit 1
fi

echo ""
echo "[SUCCESS] Project created successfully!"
echo ""
echo "You can open the project at:"
echo "  $OUTPUT_DIR/$PROJECT_NAME.xpr"
echo ""
