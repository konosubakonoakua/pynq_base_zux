# ============================================================
# PYNQ-ZUX Project Creation Script
# ============================================================
#
# This script creates a Vivado project for the PYNQ-ZUX board.
# It supports multiple FPGA parts and Vivado versions.
#
# Usage:
#   vivado -mode tcl -source project.tcl -tclargs [options]
#
# Options:
#   -part           : FPGA part (default: xczu15eg-ffvb1156-2-i)
#   -vivado_version : Vivado version (default: detected from tool)
#   -project_name   : Project name (default: pynq_base_zux)
#   -output_dir     : Output directory (default: ./build)
#   -src_dir        : Source directory (default: ./src)
#   -no_synth       : Skip synthesis run
#   -no_impl        : Skip implementation run
#
# ============================================================

namespace eval project {

# Default values
variable default_part "xczu15eg-ffvb1156-2-i"
variable default_project_name "pynq_base_zux"
variable default_vivado_version ""
variable default_output_dir ""
variable default_src_dir ""

# Current settings
variable current_part ""
variable current_version ""
variable current_project_name ""
variable current_output_dir ""
variable current_src_dir ""
variable do_synth 1
variable do_impl 1

# Source directories
variable bd_dir ""
variable constrs_dir ""
variable bd_name ""

# ============================================================
# Main Entry Point
# ============================================================

proc main {argc argv} {
    variable default_part
    variable default_project_name
    variable default_vivado_version
    variable default_output_dir
    variable current_part
    variable current_version
    variable current_project_name
    variable current_output_dir
    variable current_src_dir
    variable do_synth
    variable do_impl
    variable bd_dir
    variable constrs_dir
    variable bd_name

    # Set defaults
    set current_part $default_part
    set current_project_name $default_project_name
    set default_output_dir "[utils::get_project_root]/build"
    set current_output_dir $default_output_dir
    set current_src_dir [utils::get_default_src_dir]

    # Get Vivado version if not specified
    set default_vivado_version [utils::get_vivado_version]
    set current_version $default_vivado_version

    # Helper for options that require a value.
    set argv_len [llength $argv]

    # Parse command line arguments
    for {set i 0} {$i < $argc} {incr i} {
        set arg [lindex $argv $i]
        switch -exact -- $arg {
            "-part" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for -part"
                    return 1
                }
                set current_part [lindex $argv $i]
            }
            "-vivado_version" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for $arg"
                    return 1
                }
                set current_version [lindex $argv $i]
            }
            "-project_name" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for -project_name"
                    return 1
                }
                set current_project_name [lindex $argv $i]
            }
            "-output_dir" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for -output_dir"
                    return 1
                }
                set current_output_dir [lindex $argv $i]
            }
            "-src_dir" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for -src_dir"
                    return 1
                }
                set current_src_dir [lindex $argv $i]
            }
            "-bd_name" {
                if {[incr i] >= $argv_len} {
                    puts "  \[ERROR\] Missing value for -bd_name"
                    return 1
                }
                set bd_name [lindex $argv $i]
            }
            "-no_synth" {
                set do_synth 0
            }
            "-no_impl" {
                set do_impl 0
            }
            "-help" -
            "--help" {
                print_help
                return 0
            }
            default {
                puts "  \[ERROR\] Unknown option: $arg"
                print_help
                return 1
            }
        }
    }

    # Normalize relative paths to project root (not current shell directory).
    set project_root [utils::get_project_root]
    if {[file pathtype $current_output_dir] ne "absolute"} {
        set current_output_dir [file normalize "$project_root/$current_output_dir"]
    } else {
        set current_output_dir [file normalize $current_output_dir]
    }
    if {[file pathtype $current_src_dir] ne "absolute"} {
        set current_src_dir [file normalize "$project_root/$current_src_dir"]
    } else {
        set current_src_dir [file normalize $current_src_dir]
    }

    # Set source directories
    set bd_dir [file normalize "$current_src_dir/bd"]
    set constrs_dir [file normalize "$current_src_dir/constrs"]

    # Print configuration
    print_config

    # Validate settings
    if {[validate_settings] != 0} {
        return 1
    }

    # Create the project
    create_the_project

    puts ""
    puts "============================================================"
    puts "Project creation completed successfully!"
    puts "============================================================"
    puts ""
    puts "Project location: $current_output_dir/$current_project_name.xpr"
    puts ""

    return 0
}

# ============================================================
# Print Help
# ============================================================

proc print_help {} {
    puts ""
    puts "PYNQ-ZUX Project Creation Script"
    puts "==================================="
    puts ""
    puts "Usage:"
    puts "  vivado -mode tcl -source project.tcl -tclargs \[options\]"
    puts ""
    puts "Options:"
    puts "  -part           : FPGA part (default: xczu15eg-ffvb1156-2-i)"
    puts "                   Supported: xczu15eg-ffvb1156-2-i, xczu9eg-ffvb1156-2-i"
    puts "  -vivado_version : Vivado version (default: auto-detected)"
    puts "  -project_name   : Project name (default: pynq_base_zux)"
    puts "  -output_dir     : Output directory (default: ./build)"
    puts "  -src_dir        : Source directory (default: ./src)"
    puts "  -bd_name        : Expected BD design name (optional, e.g. base)"
    puts "  -no_synth       : Skip synthesis"
    puts "  -no_impl        : Skip implementation"
    puts "  -help, --help   : Show this help"
    puts ""
    puts "Examples:"
    puts "  vivado -mode tcl -source project.tcl -tclargs \\"
    puts "      -part xczu9eg-ffvb1156-2-i \\"
    puts "      -vivado_version 2024.2 \\"
    puts "      -output_dir ./build"
    puts ""
}

# ============================================================
# Print Configuration
# ============================================================

proc print_config {} {
    variable current_part
    variable current_version
    variable current_project_name
    variable current_output_dir
    variable current_src_dir
    variable bd_dir
    variable constrs_dir
    variable bd_name
    variable do_synth
    variable do_impl

    puts ""
    puts "============================================================"
    puts "PYNQ-ZUX Project Builder"
    puts "============================================================"
    puts ""
    puts "Configuration:"
    puts "  FPGA Part:          $current_part"
    puts "  Vivado Version:     $current_version"
    puts "  Project Name:       $current_project_name"
    puts "  Output Dir:         $current_output_dir"
    puts "  Source Dir:         $current_src_dir"
    puts "  BD Dir:             $bd_dir"
    puts "  Constraints Dir:    $constrs_dir"
    if {$bd_name eq ""} {
        puts "  BD Name:            (auto)"
    } else {
        puts "  BD Name:            $bd_name"
    }
    puts "  Run Synthesis:      $do_synth"
    puts "  Run Implementation: $do_impl"
    puts ""
}

# ============================================================
# Validate Settings
# ============================================================

proc validate_settings {} {
    variable current_part
    variable current_version
    variable current_output_dir
    variable current_project_name
    variable bd_dir
    variable constrs_dir

    set errors 0

    # Validate part
    if {![utils::validate_part $current_part]} {
        puts "  \[ERROR\] Unsupported part: $current_part"
        puts "           Supported parts: xczu15eg-ffvb1156-2-i, xczu9eg-ffvb1156-2-i"
        incr errors
    }

    # Validate version
    if {![utils::is_version_supported $current_version]} {
        puts "  \[ERROR\] Unsupported Vivado version: $current_version"
        puts "           Supported versions: [join [utils::supported_versions] {, }]"
        incr errors
    }

    # Check if BD file exists
    set bd_file [utils::find_bd_tcl $current_version $bd_dir]
    if {$bd_file eq ""} {
        puts "  \[ERROR\] BD TCL file not found for version: $current_version"
        puts "           Looked in: $bd_dir/base_*.tcl"
        puts "           Please provide the BD TCL file or specify correct version"
        incr errors
    }

    # Check if constraints file exists
    set constrs_file "$constrs_dir/pins.xdc"
    if {![file exists $constrs_file]} {
        puts "  \[ERROR\] Constraints file not found: $constrs_file"
        incr errors
    }

    # Check output directory
    if {$errors == 0 && [file exists "$current_output_dir/$current_project_name.xpr"]} {
        puts "  \[WARNING\] Project already exists: $current_output_dir/$current_project_name.xpr"
        puts "             The existing project will be overwritten"
    }

    if {$errors > 0} {
        puts ""
        puts "Validation failed with $errors error(s)"
        return 1
    }

    return 0
}

# ============================================================
# Create Project
# ============================================================

proc create_the_project {} {
    variable current_part
    variable current_version
    variable current_project_name
    variable current_output_dir
    variable current_src_dir
    variable bd_dir
    variable constrs_dir
    variable bd_name
    variable do_synth
    variable do_impl

    utils::print_banner "Creating Vivado Project"

    # Find BD file
    set bd_file [utils::find_bd_tcl $current_version $bd_dir]
    set constrs_file "$constrs_dir/pins.xdc"

    utils::print_info "Using BD file: $bd_file"
    utils::print_info "Using constraints: $constrs_file"
    utils::print_info ""

    # Create output directory
    utils::ensure_dir $current_output_dir

    # Create project
    utils::print_info "Creating project..."

    # Check if any project is currently open
    if {[catch {set proj [current_project]} result]} {
        # No project is open.
    } else {
        catch {close_project -force}
    }

    # Delete existing project if it exists
    set proj_dir "$current_output_dir/$current_project_name"
    set proj_file "$current_output_dir/$current_project_name.xpr"
    if {[file exists $proj_file] || [file exists $proj_dir]} {
        utils::print_info "Removing existing project..."
        if {[file exists $proj_dir]} {
            file delete -force $proj_dir
        }
        foreach ext [list .xpr .srcs .cache .hw .ip_user_files .runs .sim .gen .log .jou] {
            set old_file "$current_output_dir/$current_project_name$ext"
            if {[file exists $old_file]} {
                file delete -force $old_file
            }
        }
    }

    # Create project
    create_project $current_project_name $current_output_dir -part $current_part

    # Set project properties
    set obj [current_project]
    set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
    set_property -name "enable_vhdl_2008" -value "1" -objects $obj
    set_property -name "ip_cache_permissions" -value "read write" -objects $obj
    set_property -name "ip_output_repo" -value "$current_output_dir/$current_project_name.cache/ip" -objects $obj
    set_property -name "simulator_language" -value "Mixed" -objects $obj

    # Create sources fileset
    utils::print_info "Setting up sources..."
    if {[string equal [get_filesets -quiet sources_1] ""]} {
        create_fileset -srcset sources_1
    }

    # Source BD Tcl script to create the in-project .bd design.
    utils::print_info "Creating Block Design from Tcl..."
    if {[catch {source [file normalize $bd_file]} bd_err]} {
        error "Failed to source BD Tcl '$bd_file': $bd_err"
    }

    # Resolve generated BD file/design name.
    set bd_design [current_bd_design -quiet]
    if {$bd_name ne ""} {
        set bd_design $bd_name
    }
    if {$bd_design eq ""} {
        set all_bd_designs [get_bd_designs -quiet]
        if {[llength $all_bd_designs] > 0} {
            set bd_design [lindex $all_bd_designs 0]
        }
    }
    if {$bd_design eq ""} {
        error "BD Tcl completed but no block design was created."
    }

    set bd_obj [get_files -quiet "${bd_design}.bd"]
    if {$bd_obj eq ""} {
        set all_bd_files [get_files -quiet "*.bd"]
        if {[llength $all_bd_files] > 0} {
            set bd_obj [lindex $all_bd_files 0]
            set bd_design [file rootname [file tail $bd_obj]]
        }
    }
    if {$bd_obj eq ""} {
        error "No .bd file found after sourcing '$bd_file'."
    }

    # Create wrapper from the actual .bd file.
    utils::print_info "Creating wrapper..."
    set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse $bd_obj] -top]
    if {$wrapper_path eq ""} {
        error "make_wrapper returned empty path for BD '$bd_design'."
    }
    add_files -norecurse -fileset sources_1 $wrapper_path
    utils::print_info "Created wrapper: $wrapper_path"

    # Set top
    set top_name "${bd_design}_wrapper"
    set_property -name "top" -value $top_name -objects [get_filesets sources_1]

    # Create constraints fileset
    utils::print_info "Setting up constraints..."
    if {[string equal [get_filesets -quiet constrs_1] ""]} {
        create_fileset -constrset constrs_1
    }

    # Import constraints
    import_files -fileset constrs_1 [file normalize $constrs_file]
    set_property -name "file_type" -value "XDC" -objects [get_files -of_objects [get_filesets constrs_1] "*pins.xdc"]
    set_property -name "target_part" -value $current_part -objects [get_filesets constrs_1]

    # Create simulation fileset
    if {[string equal [get_filesets -quiet sim_1] ""]} {
        create_fileset -simset sim_1
    }
    set_property -name "top" -value $top_name -objects [get_filesets sim_1]
    set_property -name "top_lib" -value "xil_defaultlib" -objects [get_filesets sim_1]

    # Create synthesis run
    utils::print_info "Setting up synthesis run..."
    if {[string equal [get_runs -quiet synth_1] ""]} {
        create_run -name synth_1 -part $current_part -flow {Vivado Synthesis [string map {. ""} $current_version]} \
            -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
    } else {
        set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
    }
    set_property -name "part" -value $current_part -objects [get_runs synth_1]
    current_run -synthesis [get_runs synth_1]

    # Create implementation run
    utils::print_info "Setting up implementation run..."
    if {[string equal [get_runs -quiet impl_1] ""]} {
        create_run -name impl_1 -part $current_part -flow {Vivado Implementation [string map {. ""} $current_version]} \
            -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
    } else {
        set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
    }
    set_property -name "part" -value $current_part -objects [get_runs impl_1]
    current_run -implementation [get_runs impl_1]

    # Update project file using write_project_tcl (more reliable in Vivado 2024.x)
    set proj_tcl_file "$current_output_dir/$current_project_name.tcl"
    utils::print_info "Saving project as Tcl script: $proj_tcl_file"
    if {[catch {write_project_tcl -use_bd_files -no_copy_sources -force $proj_tcl_file} result]} {
        utils::print_warning "write_project_tcl failed: $result"
        # Try alternative: save_project_as with explicit name
        if {[catch {save_project_as -force $current_project_name} result2]} {
            utils::print_warning "save_project_as also failed: $result2"
        }
    }
    utils::print_success "Project created successfully!"
}

}

# ============================================================
# Entry Point
# ============================================================

set script_dir [file dirname [info script]]
set utils_file [file join $script_dir utils.tcl]
set ip_versions_file [file join $script_dir ip_versions.tcl]

if {[catch {source $utils_file} source_err]} {
    puts "  \[ERROR\] Failed to source utils.tcl: $source_err"
    exit 1
}

if {[catch {source $ip_versions_file} source_err]} {
    puts "  \[ERROR\] Failed to source ip_versions.tcl: $source_err"
    exit 1
}

if {[catch {project::main $::argc $::argv} result]} {
    puts "  \[ERROR\] project::main failed: $result"
    puts $::errorInfo
    exit 1
}

exit 0
