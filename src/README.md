# Source

Hardware source files.

## Structure

- `bd/` - Block Design TCL scripts
- `constrs/` - Constraints (XDC)
- `ip_repo/` - Custom IP repositories (optional)

## Block Design

The BD TCL scripts define the IP Integrator design:
- `pynq_base_zux.tcl` - Main BD script

Generated artifacts (after project creation):
- `*.bd` - Block design files
- `*.xci` - IP configuration files

## Constraints

Constraints define I/O pins and timing:
- `pins.xdc` - Pin assignments for PYNQ-ZUX

## Notes

- BD scripts use relative paths
- Framework resolves paths automatically
- Generated IP files go to build/ directory
