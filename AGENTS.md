# Repository Guidelines

## Project Structure & Module Organization
This repository is a script-driven Vivado flow for PYNQ-ZUX.

- `src/bd/`: versioned block design exports (for example `base_2024.1.tcl`, `base_2024.2.tcl`).
- `src/constrs/`: board constraints (`pins.xdc`).
- `scripts/`: entry scripts (`create_project.ps1` for Windows, `create_project.sh` for Linux).
- `scripts/tcl/`: core Tcl automation (`project.tcl`, `artifacts.tcl`, `utils.tcl`, `ip_versions.tcl`).
- `build/`: generated Vivado project/output. Do not hand-edit or commit generated artifacts.

## Build, Test, and Development Commands
Run from repository root unless noted.

- Windows project creation: `powershell -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Version 2024.2`
- Linux project creation: `./scripts/create_project.sh -version 2024.2`
- Select part/version: `... -Part xczu9eg-ffvb1156-2-i -Version 2024.2` (Windows) or `... -part xczu9eg-ffvb1156-2-i -version 2024.2` (Linux)
- Generate outputs: `vivado -mode tcl -source scripts/tcl/artifacts.tcl -tclargs -project ./build/pynq_base_zux.xpr -all -compress -debug`

## Coding Style & Naming Conventions
- Tcl is the primary source language; keep orchestration in `scripts/tcl/` and hardware sources under `src/`.
- Use 4-space indentation and small, single-purpose procedures.
- Use `snake_case` for Tcl proc/variable names and CLI flags.
- Use BD naming pattern `base_<major.minor>.tcl` (example: `base_2025.1.tcl`).
- Keep scripts ASCII unless a file already requires Unicode.

## Testing Guidelines
This repository uses flow validation instead of unit tests.

- Recreate project from a clean `build/` directory.
- Confirm Vivado exits cleanly and `build/<project>.xpr` exists.
- Confirm BD creation under `build/<project>.srcs/sources_1/bd/`.
- Run `artifacts.tcl` with required flags (`-bit`, `-bin`, `-xsa`, or `-all`) and verify outputs.

## Commit & Pull Request Guidelines
If local git history is unavailable, follow these conventions:

- Commit messages: imperative and scoped (example: `scripts: add -BdName passthrough for project.tcl`).
- Keep changes focused (script/Tcl/docs should be separable when practical).
- PRs should include target part, Vivado version, commands run, and key generated artifacts.
- Attach logs/screenshots only when diagnosing failures or behavior changes.
