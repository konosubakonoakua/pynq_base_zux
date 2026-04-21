# ============================================================
# Utility Functions for Vivado Projects
# ============================================================

namespace eval utils {

# Supported Vivado versions
variable supported_versions [list 2021.1 2022.1 2022.3 2023.1 2023.2 2024.1 2024.2]

# Supported parts
variable supported_parts {
    xczu15eg-ffvb1156-2-i
    xczu9eg-ffvb1156-2-i
}

# Get current Vivado version
proc get_vivado_version {} {
    set version [version -short]
    # Extract major.minor version (e.g., "2024.1")
    regexp {^([0-9]+\.[0-9]+)} $version full_match
    return $full_match
}

# Check if a version is supported
proc is_version_supported {version} {
    variable supported_versions
    return [expr {[lsearch -exact $supported_versions $version] >= 0}]
}

# Validate part name
proc validate_part {part} {
    variable supported_parts
    return [expr {[lsearch -exact $supported_parts $part] >= 0}]
}

# Get normalized part name
proc normalize_part {part} {
    set part [string tolower $part]
    set part [string map {-i ""} $part]
    return "xczu[string trimleft $part xczu]eg-ffvb1156-2-i"
}

# Find available BD TCL for a version
proc find_bd_tcl {version src_dir} {
    set bd_file ""

    puts "DEBUG: find_bd_tcl - version: $version, src_dir: $src_dir"

    # src_dir already contains /bd, so we don't add it again
    set bd_dir $src_dir

    # Try exact version match first
    set possible_files [list \
        "$bd_dir/base_$version.tcl" \
        "$bd_dir/base_v$version.tcl" \
    ]

    puts "DEBUG: Checking exact match: $possible_files"

    foreach file $possible_files {
        puts "DEBUG: Checking file exists: $file -> [file exists $file]"
        if {[file exists $file]} {
            set bd_file $file
            puts "DEBUG: Found BD file (exact): $bd_file"
            return $bd_file
        }
    }

    puts "DEBUG: No BD file found for version $version"
    return ""
}

# Get script directory
proc get_script_dir {} {
    set script_path [file normalize [info script]]
    return [file dirname $script_path]
}

# Get project root directory
proc get_project_root {} {
    set script_dir [get_script_dir]
    set root [file normalize "$script_dir/../.."]
    puts "DEBUG: get_project_root -> $root"
    return $root
}

# Normalize path for Windows/Linux compatibility
proc normalize_path {path} {
    if {$::tcl_platform(platform) eq "windows"} {
        return [string map {/ \\} $path]
    }
    return $path
}

# Print banner
proc print_banner {msg} {
    set width 60
    set padding [expr {($width - [string length $msg] - 2) / 2}]
    puts ""
    puts [string repeat "=" $width]
    puts "[string repeat " " $padding]$msg"
    puts [string repeat "=" $width]
    puts ""
}

# Print info message
proc print_info {msg} {
    puts "  \[INFO\] $msg"
}

# Print warning message
proc print_warning {msg} {
    puts "  \[WARNING\] $msg"
}

# Print error message
proc print_error {msg} {
    puts "  \[ERROR\] $msg"
}

# Print success message
proc print_success {msg} {
    puts "  \[SUCCESS\] $msg"
}

# Create directory if not exists
proc ensure_dir {dir} {
    if {![file exists $dir]} {
        file mkdir $dir
    }
}

# File exists with multiple possible names
proc file_exists_any {names} {
    foreach name $names {
        if {[file exists $name]} {
            return 1
        }
    }
    return 0
}

# Get first existing file from list
proc get_first_existing_file {names} {
    foreach name $names {
        if {[file exists $name]} {
            return $name
        }
    }
    return ""
}

# Check if running in Vivado
proc is_vivado {} {
    if {[info exists ::current_project]} {
        return 1
    }
    return 0
}

# Get default source directory
proc get_default_src_dir {} {
    return "[get_project_root]/src"
}

# Get default constraint directory
proc get_default_constrs_dir {} {
    return "[get_project_root]/src/constrs"
}

# Parse version string to comparable format
proc version_to_num {version} {
    scan $version "%d.%d" major minor
    return [expr {$major * 100 + $minor}]
}

# Compare versions
proc compare_versions {v1 v2} {
    set num1 [version_to_num $v1]
    set num2 [version_to_num $v2]
    if {$num1 < $num2} {return -1}
    if {$num1 > $num2} {return 1}
    return 0
}

# Get newer version
proc get_newer_version {v1 v2} {
    if {[compare_versions $v1 $v2] > 0} {
        return $v1
    }
    return $v2
}

# Get older version
proc get_older_version {v1 v2} {
    if {[compare_versions $v1 $v2] < 0} {
        return $v1
    }
    return $v2
}

# Check if version is older than reference
proc is_version_older {version ref_version} {
    return [expr {[compare_versions $version $ref_version] < 0}]
}

# Check if version is newer than reference
proc is_version_newer {version ref_version} {
    return [expr {[compare_versions $version $ref_version] > 0}]
}

}