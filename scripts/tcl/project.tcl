# ============================================================
# Vivado Project Creation Script
# ============================================================
#
# Usage:
#   vivado -mode tcl -source project.tcl -tclargs -config designs/xxx/config.tcl
#
# ============================================================

namespace eval cfg {
        variable name             ""
        variable part             ""
        variable bd_name          ""
        variable bd_tcl           ""
        variable rtl_files        ""
        variable constrs_files    ""
        variable ip_xci_files     ""
        variable coe_files        ""
        variable ip_repo          ""
        variable synth_strategy   ""
        variable impl_strategy    ""
        variable force            "0"
    }

namespace eval project {
        variable output_dir ""

        proc main {argc argv} {
        set config_file [get_config_file $argc $argv]
        load_config $config_file
        validate_config
        create_the_project
    }

    proc get_config_file {argc argv} {
        set project_root [utils::get_project_root]

        set design_name ""
        set cfg::force false

        for {set i 0} {$i < $argc} {incr i} {
            set arg [lindex $argv $i]
            if {$arg eq "-design" || $arg eq "-d"} {
                set design_name [lindex $argv [expr {$i + 1}]]
                incr i
            } elseif {$arg eq "-force" || $arg eq "-f"} {
                set cfg::force true
            } elseif {$arg eq "-config"} {
                return [lindex $argv [expr {$i + 1}]]
            } elseif {$arg eq "-verbose"} {
                log::set_level "DEBUG"
            }
        }

        if {$design_name ne ""} {
            set config_file "$project_root/designs/$design_name/config.tcl"
            if {[file exists $config_file]} {
                return $config_file
            }
            error "Design not found: designs/$design_name/config.tcl"
        }

        error "Design name required. Use: -design <name>\nExample: -design pynq_base_zux"
    }

    # ============================================================
    # Load Config
    # ============================================================

    proc load_config {config_file} {
        if {![file exists $config_file]} {
            error "Config file not found: $config_file"
        }

        set design_dir [file dirname $config_file]
        set project_root [utils::get_project_root]

        source $config_file

        set cfg::bd_tcl [file normalize "$project_root/$cfg::bd_tcl"]

        set cfg::constrs_files [norm_files $project_root $cfg::constrs_files]
        set cfg::rtl_files [norm_files $project_root $cfg::rtl_files]
        set cfg::ip_xci_files [norm_files $project_root $cfg::ip_xci_files]
        set cfg::coe_files [norm_files $project_root $cfg::coe_files]

        if {$cfg::ip_repo ne ""} {
            set cfg::ip_repo [file normalize "$project_root/$cfg::ip_repo"]
        }
    }

    proc norm_files {root patterns} {
        set result {}
        foreach p $patterns {
            if {$p eq ""} { continue }
            lappend result [file normalize "$root/$p"]
        }
        return $result
    }

    # ============================================================
    # Validate
    # ============================================================

    proc validate_config {} {
        if {$cfg::name eq ""}   { error "cfg::name required" }
        if {$cfg::part eq ""}   { error "cfg::part required" }
        if {$cfg::bd_tcl eq ""} { error "cfg::bd_tcl required" }
        if {![utils::validate_part $cfg::part]} {
            error "Unsupported part: $cfg::part"
        }
        if {![file exists $cfg::bd_tcl]} {
            error "BD file not found: $cfg::bd_tcl"
        }
    }

    # ============================================================
    # Create Project
    # ============================================================

    proc create_the_project {} {
        variable output_dir
        set output_dir "[utils::get_project_root]/build/$cfg::name"

        log::info "Creating project: $cfg::name"

        set proj_file "$output_dir/$cfg::name.xpr"
        if {[file exists $proj_file]} {
            if {$cfg::force} {
                file delete -force "$output_dir"
            } else {
                error "Project already exists. Use -force to overwrite."
            }
        }

        if {$cfg::force} {
            create_project $cfg::name $output_dir -part $cfg::part -force
        } else {
            create_project $cfg::name $output_dir -part $cfg::part
        }

        set obj [current_project]
        set_property default_lib xil_defaultlib $obj
        set_property enable_vhdl_2008 1 $obj
        set_property ip_cache_permissions "read write" $obj
        set_property ip_output_repo "$output_dir.cache/ip" $obj

        add_source_files
        add_constr_files
        add_ip_files
        add_coe_files
        add_ip_repo
        create_bd
        create_runs

        log::success "Project created: $proj_file"
    }

    # ============================================================
    # Add Source Files
    # ============================================================

    proc add_source_files {} {
        if {$cfg::rtl_files eq ""} { return }
        log::info "Adding [llength $cfg::rtl_files] RTL files"
        if {[string equal [get_filesets -quiet sources_1] ""]} {
            create_fileset -srcset sources_1
        }
        add_files -fileset sources_1 $cfg::rtl_files

        log::info "Setting up simulation"
        if {[string equal [get_filesets -quiet sim_1] ""]} {
            create_fileset -simset sim_1
        }
        set_property top "$cfg::name" [get_filesets sim_1]
    }

    proc add_constr_files {} {
        if {$cfg::constrs_files eq ""} { return }
        log::info "Adding [llength $cfg::constrs_files] constraint files"
        if {[string equal [get_filesets -quiet constrs_1] ""]} {
            create_fileset -constrset constrs_1
        }
        add_files -fileset constrs_1 $cfg::constrs_files
        set_property target_part $cfg::part [get_filesets constrs_1]
    }

    proc add_ip_files {} {
        if {$cfg::ip_xci_files eq ""} { return }
        log::info "Adding [llength $cfg::ip_xci_files] IP files"
        create_fileset -srcset sources_1
        foreach f $cfg::ip_xci_files {
            if {[file exists $f]} {
                add_files -fileset sources_1 $f
            }
        }
    }

    proc add_coe_files {} {
        if {$cfg::coe_files eq ""} { return }
        log::info "Adding [llength $cfg::coe_files] COE files"
    }

    proc add_ip_repo {} {
        if {$cfg::ip_repo eq ""} { return }
        if {![file exists $cfg::ip_repo]} { return }
        log::info "Setting IP repo: $cfg::ip_repo"
        set_property ip_repo_paths $cfg::ip_repo [current_project]
    }

    # ============================================================
    # Create BD
    # ============================================================

    proc create_bd {} {
        log::info "Creating BD from: $cfg::bd_tcl"
        source $cfg::bd_tcl

        set bd [current_bd_design -quiet]
        if {$cfg::bd_name ne ""} { set bd $cfg::bd_name }
        if {$bd eq ""} {
            set bd [lindex [get_bd_designs -quiet] 0]
        }

        set bd_obj [get_files -quiet "${bd}.bd"]
        if {$bd_obj eq ""} {
            set bd_obj [lindex [get_files -quiet "*.bd"] 0]
        }

        set wrapper [make_wrapper -fileset sources_1 -files [get_files -norecurse $bd_obj] -top]
        add_files -norecurse -fileset sources_1 $wrapper

        set top "${bd}_wrapper"
        set_property top $top [get_filesets sources_1]
    }

    # ============================================================
    # Create Runs
    # ============================================================

    proc create_runs {} {
        set ver [string map {. ""} [utils::get_vivado_version]]

        set synth [get_runs -quiet synth_1]
        set impl [get_runs -quiet impl_1]

        if {$synth eq ""} {
            log::info "Creating synthesis run"
            set synth [create_run -name synth_1 -part $cfg::part \
                -flow "Vivado Synthesis $ver" \
                -strategy "$cfg::synth_strategy" \
                -report_strategy {No Reports} \
                -constrset constrs_1]
        } else {
            log::info "Configuring synthesis run"
            set_property strategy $cfg::synth_strategy $synth
            set_property part $cfg::part $synth
        }
        current_run -synthesis $synth

        if {$impl eq ""} {
            log::info "Creating implementation run"
            set impl [create_run -name impl_1 -part $cfg::part \
                -flow "Vivado Implementation $ver" \
                -strategy "$cfg::impl_strategy" \
                -report_strategy {No Reports} \
                -constrset constrs_1 \
                -parent_run $synth]
        } else {
            log::info "Configuring implementation run"
            set_property strategy $cfg::impl_strategy $impl
            set_property part $cfg::part $impl
        }
        current_run -implementation $impl
    }

}

# ============================================================
# Entry Point
# ============================================================

set script_dir [file dirname [info script]]

if {[catch {
    source [file join $script_dir utils.tcl]
    project::main $::argc $::argv
} err]} {
    log::error $err
    puts $::errorInfo
    exit 1
}

exit 0
