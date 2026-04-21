<#
.SYNOPSIS
  Cleans generated Vivado artifacts for this repository.

.DESCRIPTION
  Removes the generated `build/` directory and top-level Vivado log/journal files.
  Uses PowerShell's ShouldProcess, so `-WhatIf` is supported.

.EXAMPLE
  # Preview what would be deleted
  .\scripts\clean.ps1 -WhatIf

.EXAMPLE
  # Remove build outputs and logs
  .\scripts\clean.ps1
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
param(
  [switch]$Build,
  [switch]$Logs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $PSCommandPath
$ProjectDir = Split-Path -Parent $ScriptDir

function Test-IsUnderProjectRoot {
  param([Parameter(Mandatory = $true)][string]$Path)

  $projectRoot = [IO.Path]::GetFullPath($ProjectDir).TrimEnd("\")
  $full = [IO.Path]::GetFullPath($Path)
  return $full.StartsWith($projectRoot, [StringComparison]::OrdinalIgnoreCase)
}

function Remove-PathSafe {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-IsUnderProjectRoot -Path $Path)) {
    throw "Refusing to delete outside project root: $Path"
  }

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  if ($PSCmdlet.ShouldProcess($Path, "Remove")) {
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
    Write-Host "Removed: $Path"
  }
}

function Remove-RootMatches {
  param([Parameter(Mandatory = $true)][string[]]$Patterns)

  foreach ($pattern in $Patterns) {
    Get-ChildItem -LiteralPath $ProjectDir -File -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
      Remove-PathSafe -Path $_.FullName
    }
  }
}

# Default behavior: clean both build and logs unless user selected a subset.
$doBuild = $Build -or (-not $PSBoundParameters.ContainsKey("Build") -and -not $PSBoundParameters.ContainsKey("Logs"))
$doLogs  = $Logs  -or (-not $PSBoundParameters.ContainsKey("Build") -and -not $PSBoundParameters.ContainsKey("Logs"))

if ($doBuild) {
  Remove-PathSafe -Path (Join-Path $ProjectDir "build")
}

if ($doLogs) {
  # Only remove top-level logs/journals; do not recurse into sources.
  Remove-RootMatches -Patterns @(
    "vivado*.jou",
    "vivado*.log",
    "vivado_pid*.str",
    "*.backup.jou",
    "*.backup.log"
  )
}
