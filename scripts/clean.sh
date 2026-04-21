#!/bin/bash
# =============================================================================
# Clean Vivado build artifacts
# =============================================================================
# Removes the generated `build/` directory and top-level Vivado log/journal files.
#
# Usage:
#   ./scripts/clean.sh           # Clean both build and logs
#   ./scripts/clean.sh --build  # Clean only build directory
#   ./scripts/clean.sh --logs   # Clean only log files
#   ./scripts/clean.sh --help   # Show help
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

clean_build() {
    if [ -d "$PROJECT_DIR/build" ]; then
        rm -rf "$PROJECT_DIR/build"
        echo "Removed: build/"
    else
        echo "No build/ directory to remove"
    fi
}

clean_logs() {
    cd "$PROJECT_DIR"
    rm -f vivado*.jou vivado*.log vivado*.str *.backup.jou *.backup.log 2>/dev/null || true
    echo "Removed: top-level logs and journals"
}

clean_help() {
    cat << EOF
Clean Vivado build artifacts

Usage: $0 [OPTIONS]

Options:
  --build    Clean only build directory
  --logs    Clean only log files
  --help    Show this help

By default, cleans both build and logs.
EOF
}

# Parse arguments
CLEAN_BUILD=true
CLEAN_LOGS=true

while [ $# -gt 0 ]; do
    case "$1" in
        --build)
            CLEAN_LOGS=false
            shift
            ;;
        --logs)
            CLEAN_BUILD=false
            shift
            ;;
        --help|-h)
            clean_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            clean_help
            exit 1
            ;;
    esac
done

# Execute
if $CLEAN_BUILD; then
    clean_build
fi

if $CLEAN_LOGS; then
    clean_logs
fi

echo "Done"