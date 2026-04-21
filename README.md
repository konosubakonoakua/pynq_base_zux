# PYNQ-ZUX Vivado Project

Script-driven Vivado project for PYNQ on Zynq UltraScale+ (`xczu15eg-ffvb1156-2-i`, `xczu9eg-ffvb1156-2-i`).

## Supported Vivado + BD Sources

| Vivado | BD Tcl source |
|---|---|
| 2024.1 | `src/bd/base_2024.1.tcl` |
| 2024.2 | `src/bd/base_2024.2.tcl` |

If you use another Vivado version, export a matching BD Tcl into `src/bd/` (see "Adding a New BD Version").

## Quick Start

### Windows (recommended)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Version 2024.2
```

Common options:

```powershell
# ZU9 target
powershell -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Version 2024.2 -Part xczu9eg-ffvb1156-2-i

# Force BD design name expected by the flow
powershell -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Version 2024.2 -BdName base
```

### Linux

```bash
chmod +x scripts/create_project.sh
./scripts/create_project.sh -version 2024.2
```

## Create-Project Options

### PowerShell (`scripts/create_project.ps1`)

- `-Version` (mapped to Tcl `-vivado_version`)
- `-Part`
- `-ProjectName`
- `-OutputDir` (default: `<repo>/build`)
- `-BdName` (optional)

### Bash (`scripts/create_project.sh`)

- `-version`
- `-part`
- `-project_name`
- `-output_dir`

## Generate Artifacts

Run from repository root:

```bash
vivado -mode tcl -source scripts/tcl/artifacts.tcl -tclargs \
  -project ./build/pynq_base_zux.xpr \
  -all -compress -debug
```

Main flags: `-bit`, `-bin`, `-xsa`, `-all`, `-compress`, `-debug`.

## Project Structure

```text
prj/
|- scripts/
|  |- create_project.ps1
|  |- create_project.sh
|  `- tcl/
|     |- project.tcl
|     |- artifacts.tcl
|     |- utils.tcl
|     `- ip_versions.tcl
|- src/
|  |- bd/
|  |  |- base_2024.1.tcl
|  |  `- base_2024.2.tcl
|  `- constrs/
|     `- pins.xdc
`- build/  (generated, do not edit)
```

## Adding a New BD Version

1. Open the project in the target Vivado version.
2. Export Block Design Tcl.
3. Save as `src/bd/base_<major.minor>.tcl` (example: `base_2025.1.tcl`).
4. Ensure `scripts/tcl/utils.tcl` includes the version in `supported_versions`.
