# ============================================================
# Generate Artifacts Script (bit/bin/xsa)
# ============================================================
#
# This script generates bitstream, binary, and XSA files.
#
# Usage:
#   vivado -mode tcl -source artifacts.tcl -tclargs [options]
#
# Options:
#   -project      : Project file (.xpr)
#   -bit          : Generate bitstream
#   -bin          : Generate bin file (bitstream only)
#   -xsa          : Generate XSA file (old format)
#   -compress     : Enable bitstream compression
#   -debug        : Include debug probes
#   -all          : Generate all outputs
#   -force        : Overwrite existing files
#   -output_dir   : Output directory (default: project directory)
#
# ============================================================

namespace eval gen_outputs {

variable project_file ""
variable do_bit 0
variable do_bin 0
variable do_xsa 0
variable compress 1
variable debug 1
variable force 0
variable output_dir ""

# ============================================================
# Main Entry Point
# ============================================================

proc main {argc argv} {
    variable project_file
    variable do_bit
    variable do_bin
    variable do_xsa
    variable compress
    variable debug
    variable force
    variable output_dir

    # Parse arguments
    for {set i 0} {$i < $argc} {incr i} {
        set arg [lindex $argv $i]
        switch -exact -- $arg {
            "-project" {
                incr i
                set project_file [lindex $argv $i]
            }
            "-bit" {
                set do_bit 1
            }
            "-bin" {
                set do_bin 1
            }
            "-xsa" {
                set do_xsa 1
            }
            "-all" {
                set do_bit 1
                set do_bin 1
                set do_xsa 1
            }
            "-compress" {
                set compress 1
            }
            "-nocompress" {
                set compress 0
            }
            "-debug" {
                set debug 1
            }
            "-nodebug" {
                set debug 0
            }
            "-force" {
                set force 1
            }
            "-output_dir" {
                incr i
                set output_dir [lindex $argv $i]
            }
            "-help" {
                print_help
                return 0
            }
            default {
                puts "Unknown option: $arg"
                print_help
                return 1
            }
        }
    }

    # If no output specified, show help
    if {!$do_bit && !$do_bin && !$do_xsa} {
        print_help
        return 1
    }

    # Validate settings
    if {[validate_settings] != 0} {
        return 1
    }

    # Open project
    open_project

    # Generate outputs
    generate_outputs

    puts ""
    puts "============================================================"
    puts "Output generation completed!"
    puts "============================================================"
    puts ""

    return 0
}

# ============================================================
# Print Help
# ============================================================

proc print_help {} {
    puts ""
    puts "Generate Outputs Script"
    puts "========================"
    puts ""
    puts "Usage:"
    puts "  vivado -mode tcl -source artifacts.tcl -tclargs \[options\]"
    puts ""
    puts "Options:"
    puts "  -project      : Project file (.xpr)"
    puts "  -bit          : Generate bitstream"
    puts "  -bin          : Generate bin file (bitstream only)"
    puts "  -xsa          : Generate XSA file (old format)"
    puts "  -all          : Generate all outputs"
    puts "  -compress     : Enable compression (default)"
    puts "  -nocompress   : Disable compression"
    puts "  -debug        : Include debug probes (default)"
    puts "  -nodebug      : Exclude debug probes"
    puts "  -force        : Overwrite existing files"
    puts "  -output_dir   : Output directory"
    puts "  -help         : Show this help"
    puts ""
    puts "Example:"
    puts "  vivado -mode tcl -source artifacts.tcl -tclargs \\"
    puts "      -project ./build/pynq_base_zux.xpr \\"
    puts "      -all \\"
    puts "      -compress \\"
    puts "      -debug"
    puts ""
}

# ============================================================
# Validate Settings
# ============================================================

proc validate_settings {} {
    variable project_file

    set errors 0

    if {$project_file eq ""} {
        puts "  \[ERROR\] Project file not specified"
        incr errors
    } elseif {![file exists $project_file]} {
        puts "  \[ERROR\] Project file not found: $project_file"
        incr errors
    }

    if {$errors > 0} {
        return 1
    }

    return 0
}

# ============================================================
# Open Project
# ============================================================

proc open_project {} {
    variable project_file

    utils::print_banner "Opening Project"

    open_project $project_file

    set proj_dir [get_property directory [current_project]]
    set proj_name [get_property name [current_project]]

    puts "  Project: $proj_name"
    puts "  Directory: $proj_dir"
    puts ""
}

# ============================================================
# Generate Outputs
# ============================================================

proc generate_outputs {} {
    variable do_bit
    variable do_bin
    variable do_xsa
    variable compress
    variable debug
    variable force
    variable output_dir

    set proj_dir [get_property directory [current_project]]
    set proj_name [get_property name [current_project]]

    if {$output_dir eq ""} {
        set output_dir $proj_dir
    }

    # Set current impl run
    current_run -implementation [get_runs impl_1]

    # Generate bitstream first (needed for bin and xsa)
    if {$do_bit || $do_bin} {
        generate_bitstream
    }

    if {$do_xsa} {
        generate_xsa
    }

    utils::print_success "All outputs generated successfully!"
}

# ============================================================
# Generate Bitstream
# ============================================================

proc generate_bitstream {} {
    variable compress
    variable debug
    variable force
    variable output_dir

    utils::print_info "Generating bitstream..."

    set proj_dir [get_property directory [current_project]]
    set proj_name [get_property name [current_project]]

    # Build options
    set options ""

    if {$compress} {
        append options " -compress"
    }

    if {$debug} {
        append options " -debug_bitstream"
    }

    if {$force} {
        append options " -force"
    }

    # Determine output path
    set bit_file "$output_dir/$proj_name.bit"

    # Generate bitstream
    write_bit_stream $bit_file$options

    utils::print_success "Bitstream generated: $bit_file"
}

# ============================================================
# Generate BIN (bitstream only)
# ============================================================

proc generate_bin {} {
    variable compress
    variable debug
    variable force
    variable output_dir

    utils::print_info "Generating BIN file..."

    set proj_dir [get_property directory [current_project]]
    set proj_name [get_property name [current_project]]

    # Build options
    set options " -bin_file"

    if {$compress} {
        append options " -compress"
    }

    if {$debug} {
        append options " -debug_bitstream"
    }

    if {$force} {
        append options " -force"
    }

    # Determine output path
    set bin_file "$output_dir/$proj_name.bin"

    # Generate bin
    write_bit_stream $bin_file$options

    utils::print_success "BIN generated: $bin_file"
}

# ============================================================
# Generate XSA
# ============================================================

proc generate_xsa {} {
    variable force
    variable output_dir

    utils::print_info "Generating XSA file..."

    set proj_dir [get_property directory [current_project]]
    set proj_name [get_property name [current_project]]

    # Build options
    set options ""

    if {$force} {
        append options " -force"
    }

    # Determine output path
    set xsa_file "$output_dir/$proj_name.xsa"

    # Generate XSA (old style)
    write_hw_platform $xsa_file$options

    utils::print_success "XSA generated: $xsa_file"
}

}

# ============================================================
# Entry Point
# ============================================================

# Load utility functions
source [file join [file dirname [info script]] utils.tcl]

# Run main
gen_outputs::main $::argc $::argv

