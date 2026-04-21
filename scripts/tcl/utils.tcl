# ============================================================
# Utility Functions for Vivado Projects
# ============================================================

namespace eval log {

variable level "INFO"

proc set_level {lvl} {
    variable level
    if {[lsearch -exact [list DEBUG INFO WARN ERROR] $lvl] >= 0} {
        set level $lvl
    }
}

proc debug {msg} {
    variable level
    if {$level eq "DEBUG"} {
        puts "  \[DEBUG\] $msg"
    }
}

proc info {msg} {
    puts "  \[INFO\]  $msg"
}

proc warn {msg} {
    puts "  \[WARN\]  $msg"
}

proc error {msg} {
    puts "  \[ERROR\] $msg"
}

proc success {msg} {
    puts "  \[SUCCESS\] $msg"
}

}

namespace eval utils {

variable supported_versions [list 2021.1 2022.1 2022.3 2023.1 2023.2 2024.1 2024.2]

variable supported_parts {
    xczu15eg-ffvb1156-2-i
    xczu9eg-ffvb1156-2-i
}

proc get_vivado_version {} {
    regexp {^([0-9]+\.[0-9]+)} [version -short] full_match
    return $full_match
}

proc is_version_supported {version} {
    variable supported_versions
    return [expr {[lsearch -exact $supported_versions $version] >= 0}]
}

proc validate_part {part} {
    variable supported_parts
    return [expr {[lsearch -exact $supported_parts $part] >= 0}]
}

proc find_bd_tcl {src_dir {fallback "base.tcl"}} {
    set bd_file "$src_dir/$fallback"
    if {[file exists $bd_file]} {
        log::debug "Found BD file: $bd_file"
        return $bd_file
    }
    log::error "BD file not found: $bd_file"
    return ""
}

proc get_script_dir {} {
    return [file dirname [file normalize [info script]]]
}

proc get_project_root {} {
    set script_dir [get_script_dir]
    return [file normalize "$script_dir/../.."]
}

proc normalize_path {path} {
    if {$::tcl_platform(platform) eq "windows"} {
        return [string map {/ \\} $path]
    }
    return $path
}

proc banner {msg} {
    set width 60
    set padding [expr {($width - [string length $msg] - 2) / 2}]
    puts ""
    puts [string repeat "=" $width]
    puts "[string repeat " " $padding]$msg"
    puts [string repeat "=" $width]
    puts ""
}

proc ensure_dir {dir} {
    if {![file exists $dir]} {
        file mkdir $dir
    }
}

proc file_exists_any {names} {
    foreach name $names {
        if {[file exists $name]} {
            return 1
        }
    }
    return 0
}

proc get_first_existing_file {names} {
    foreach name $names {
        if {[file exists $name]} {
            return $name
        }
    }
    return ""
}

proc is_vivado {} {
    if {[info exists ::current_project]} {
        return 1
    }
    return 0
}

proc get_default_src_dir {} {
    return "[get_project_root]/src"
}

proc get_default_constrs_dir {} {
    return "[get_project_root]/src/constrs"
}

proc version_to_num {version} {
    scan $version "%d.%d" major minor
    return [expr {$major * 100 + $minor}]
}

proc compare_versions {v1 v2} {
    set num1 [version_to_num $v1]
    set num2 [version_to_num $v2]
    if {$num1 < $num2} {return -1}
    if {$num1 > $num2} {return 1}
    return 0
}

}
