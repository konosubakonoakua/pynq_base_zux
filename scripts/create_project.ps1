<#
.SYNOPSIS
  Create the PYNQ-ZUX Vivado project on Windows.

.DESCRIPTION
  Calls Vivado with `-tclargs` using an argument-array invocation pattern.
  Note: `-version` conflicts with Vivado CLI parsing, so this launcher passes
  project Tcl's `-vivado_version` argument instead.

.EXAMPLE
  .\create_project.ps1

.EXAMPLE
  .\create_project.ps1 -Version 2024.2 -Part xczu9eg-ffvb1156-2-i
#>

param(
  [string]$Part = "xczu15eg-ffvb1156-2-i",
  [string]$Version = "2024.2",
  [string]$ProjectName = "pynq_base_zux",
  [string]$BdName = "",
  [string]$OutputDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$ProjectTcl = Join-Path $ScriptDir "tcl\project.tcl"

if (-not $OutputDir) {
  $OutputDir = Join-Path $ProjectDir "build"
}

$VivadoPath = Join-Path "C:\Xilinx\Vivado\$Version\bin" "vivado.bat"
if (-not (Test-Path $VivadoPath)) {
  if ($env:VIVADO_PATH -and (Test-Path $env:VIVADO_PATH)) {
    $VivadoPath = $env:VIVADO_PATH
  } else {
    throw "Vivado not found. Expected '$VivadoPath' or a valid VIVADO_PATH."
  }
}

if (-not (Test-Path $ProjectTcl)) {
  throw "Missing Tcl entrypoint: $ProjectTcl"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "============================================================"
Write-Host "PYNQ-ZUX Project Builder (PowerShell)"
Write-Host "============================================================"
Write-Host ""
Write-Host "Vivado Path:   $VivadoPath"
Write-Host "Part:          $Part"
Write-Host "Version:       $Version"
Write-Host "Project Name:  $ProjectName"
if ($BdName) { Write-Host "BD Name:       $BdName" }
Write-Host "Output Dir:    $OutputDir"
Write-Host "Project Tcl:   $ProjectTcl"
Write-Host ""

$vivadoArgs = @(
  "-mode", "tcl",
  "-source", $ProjectTcl,
  "-tclargs",
  "-part", $Part,
  "-vivado_version", $Version,
  "-project_name", $ProjectName,
  "-output_dir", $OutputDir
)
if ($BdName) {
  $vivadoArgs += @("-bd_name", $BdName)
}

& $VivadoPath @vivadoArgs
$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "Vivado finished with exit code: $exitCode"

if ($exitCode -ne 0) {
  throw "[ERROR] Project creation failed."
}

Write-Host ""
Write-Host "[SUCCESS] Project created successfully!"
Write-Host "Project file: $(Join-Path $OutputDir "$ProjectName.xpr")"
