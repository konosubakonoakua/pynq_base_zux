# Create project
create design:
    pwsh -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Design {{design}}

# Create with force
force design:
    pwsh -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Design {{design}} -Force

# Clean build and logs
clean:
    bash scripts/clean.sh

# Clean build only
clean-build:
    bash scripts/clean.sh --build

# Clean logs only
clean-logs:
    bash scripts/clean.sh --logs

# List designs
designs:
    @ls -1 designs/

# Default design
default:
    @echo "pynq_base_zu15"

# Help
help:
    @echo "Usage: just create <design-name>"
    @echo "       just force <design-name> (overwrite)"
    @echo ""
    @echo "Available designs: pynq_base_zu15 (default), pynq_base_zu9"
    @echo ""
    @echo "IMPORTANT: Use DESIGN= variable with make:"
    @echo "  make create DESIGN=pynq_base_zu9"