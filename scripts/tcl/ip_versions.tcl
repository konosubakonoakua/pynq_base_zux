# ============================================================
# IP Versions Mapping Table
# ============================================================
#
# This file contains IP version mappings for different Vivado
# versions. The mappings are used to determine which IP
# versions are compatible with each Vivado release.
#
# Format:
#   dict set ip_version_map <ip_name> <source_version> <target_vivado_version> <target_ip_version>
#
# ============================================================

namespace eval ip_versions {

# Global IP version mapping dictionary
# Key structure: ip_name -> source_version -> vivado_version -> target_version
variable ip_version_map

# Shared supported Vivado versions in this repository.
variable supported_vivado_versions [list 2021.1 2022.1 2022.3 2023.1 2023.2 2024.1 2024.2]

# Add one source-version mapping across a list of Vivado versions.
proc add_mapping {ip_name source_version target_ip_version vivado_versions} {
    variable ip_version_map
    foreach vivado_version $vivado_versions {
        dict set ip_version_map $ip_name $source_version $vivado_version $target_ip_version
    }
}

# Initialize the mapping dictionary
proc init_ip_versions {} {
    variable ip_version_map
    variable supported_vivado_versions

    # Rebuild from scratch when re-initializing.
    set ip_version_map [dict create]

    # Special-case mappings where target IP version changes by Vivado release.
    add_mapping clk_wiz         6.0 5.3 [list 2021.1 2022.1 2022.3]
    add_mapping clk_wiz         6.0 6.0 [list 2023.1 2023.2 2024.1 2024.2]
    add_mapping clk_wiz         5.3 5.3 [list 2021.1 2022.1 2022.3 2023.1]

    add_mapping zynq_ultra_ps_e 3.5 3.3 [list 2021.1 2022.1 2022.3 2023.1]
    add_mapping zynq_ultra_ps_e 3.5 3.5 [list 2023.2 2024.1 2024.2]
    add_mapping zynq_ultra_ps_e 3.3 3.3 [list 2021.1 2022.1 2022.3 2023.1 2023.2 2024.1]

    add_mapping axi_dma         7.1 7.0 [list 2021.1 2022.1 2022.3]
    add_mapping axi_dma         7.1 7.1 [list 2023.1 2023.2 2024.1 2024.2]
    add_mapping axi_dma         7.0 7.0 [list 2021.1 2022.1 2022.3]

    # Straight-through mappings across all supported Vivado versions.
    foreach {ip_name source_version target_version} {
        axi_gpio         2.0  2.0
        system_ila       1.1  1.1
        proc_sys_reset   5.0  5.0
        smartconnect     1.0  1.0
        debug_bridge     3.0  3.0
        axis_data_fifo   2.0  2.0
        axi_intc         4.1  4.1
        axi_timer        2.0  2.0
        xlconcat         2.1  2.1
        xlconstant       1.1  1.1
        xlslice          1.0  1.0
        c_counter_binary 12.0 12.0
    } {
        add_mapping $ip_name $source_version $target_version $supported_vivado_versions
    }

    return $ip_version_map
}

# Get compatible IP version for a given Vivado version
proc get_compatible_ip_version {ip_name source_version target_vivado_version} {
    variable ip_version_map

    if {![info exists ip_version_map] || [dict size $ip_version_map] == 0} {
        init_ip_versions
    }

    set key [dict exists $ip_version_map $ip_name $source_version $target_vivado_version]

    if {$key} {
        return [dict get $ip_version_map $ip_name $source_version $target_vivado_version]
    }

    # If no mapping found, return source version
    puts "  \[WARNING\] No IP version mapping for $ip_name:$source_version -> $target_vivado_version, keeping original"
    return $source_version
}

# Check if an IP version exists in a given Vivado version
proc check_ip_version_exists {ip_name version vivado_version} {
    variable ip_version_map

    if {![info exists ip_version_map] || [dict size $ip_version_map] == 0} {
        init_ip_versions
    }

    # Try direct lookup
    if {[dict exists $ip_version_map $ip_name $version $vivado_version]} {
        return 1
    }

    # Try to find any version that works
    if {[dict exists $ip_version_map $ip_name]} {
        foreach {src_ver} [dict keys [dict get $ip_version_map $ip_name]] {
            if {[dict exists $ip_version_map $ip_name $src_ver $vivado_version]} {
                return 1
            }
        }
    }

    return 0
}

# Initialize on load
init_ip_versions

}
