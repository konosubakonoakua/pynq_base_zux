# ============================================================
# Vivado Project Configuration
# ============================================================
#
# Usage:
#   make create DESIGN=pynq_base_zu15
#   make create DESIGN=pynq_base_zu9
#   just create
#
# ============================================================
# Config Variables
# ============================================================
#
# Required:
#   cfg::name    - Project name
#   cfg::part    - FPGA part (e.g., xczu15eg-ffvb1156-2-i)
#   cfg::bd_tcl  - BD Tcl file path (relative to repo root)
#
# Optional:
#   cfg::bd_name            - BD design name
#   cfg::rtl_files          - RTL file list
#   cfg::constrs_files      - Constraint file list
#   cfg::ip_xci_files       - IP file list
#   cfg::coe_files          - COE file list
#   cfg::ip_repo            - IP repo directory
#   cfg::synth_strategy     - Synthesis strategy
#   cfg::impl_strategy      - Implementation strategy
#
# ============================================================

# Required
set cfg::name "pynq_base_zu15"
set cfg::part "xczu15eg-ffvb1156-2-i"

set cfg::bd_name "base"
set cfg::bd_tcl "src/bd/pynq_base_zux.tcl"

set cfg::rtl_files {
}

set cfg::constrs_files {
    src/constrs/pins.xdc
}

set cfg::ip_xci_files {
}

set cfg::coe_files {
}

set cfg::ip_repo "src/ip_repo"

set cfg::synth_strategy "Vivado Synthesis Defaults"
set cfg::impl_strategy "Vivado Implementation Defaults"