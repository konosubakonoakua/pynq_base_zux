# Scripts

Entry scripts and automation for Vivado project creation.

## Structure

- `create_project.ps1` - Windows PowerShell wrapper
- `create_project.sh` - Linux/Bash wrapper
- `clean.ps1` - Windows clean script
- `clean.sh` - Linux clean script
- `tcl/` - Tcl automation framework
  - `project.tcl` - Main project creation logic
  - `utils.tcl` - Utility procedures

## Create Project

```powershell
# Windows
pwsh -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Design pynq_base_zu15

# Linux
bash scripts/create_project.sh -design pynq_base_zu15
```

## Clean

```powershell
# Windows - clean both
pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1

# Windows - build only
pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1 -Build

# Windows - logs only
pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1 -Logs

# Linux - clean both
bash scripts/clean.sh

# Linux - build only
bash scripts/clean.sh --build

# Linux - logs only
bash scripts/clean.sh --logs
```

## Alternative Entry Points

```bash
# Via Makefile
make create
make clean
make clean-build
make clean-logs

# Via just
just create pynq_base_zu15
just clean
just clean-build
just clean-logs
```

## Tcl Framework

The `tcl/project.tcl` framework provides:
- Config loading from designs/*/config.tcl
- Project creation with BD
- Run management (synth/impl)
- Force overwrite support