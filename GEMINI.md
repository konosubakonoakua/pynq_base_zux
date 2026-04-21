# Gemini Workspace Configuration

## Project Overview

This workspace builds a reproducible Vivado project for PYNQ-ZUX platforms.

- Devices: `xczu15eg-ffvb1156-2-i` (default), `xczu9eg-ffvb1156-2-i`
- Source-of-truth inputs:
  - Block design Tcl: `src/bd/base_*.tcl`
  - Constraints: `src/constrs/pins.xdc`
- Core automation: `scripts/tcl/project.tcl`

## Build Flows

### Windows (primary)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Version 2024.2
```

Optional flags: `-Part`, `-ProjectName`, `-OutputDir`, `-BdName`.

### Linux

```bash
chmod +x scripts/create_project.sh
./scripts/create_project.sh -version 2024.2
```

The generated project is expected at `build/pynq_base_zux.xpr` (or your custom `-OutputDir` / `-output_dir`).

## Artifact Generation

```bash
vivado -mode tcl -source scripts/tcl/artifacts.tcl -tclargs \
  -project ./build/pynq_base_zux.xpr \
  -all -compress -debug
```

Use flags like `-bit`, `-bin`, `-xsa`, or `-all` depending on required outputs.

## Conventions

- Treat `build/` as disposable generated content.
- Keep project logic in `scripts/tcl/`; avoid manual edits inside `.xpr` projects.
- Keep BD files versioned as `src/bd/base_<major.minor>.tcl`.
- When adding a version, add the BD Tcl file and update `supported_versions` in `scripts/tcl/utils.tcl`.

## Notes

`project.tcl` uses `-vivado_version` as its canonical version argument. The PowerShell wrapper already maps `-Version` to this Tcl argument.
