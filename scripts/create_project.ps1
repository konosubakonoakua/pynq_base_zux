<#
.SYNOPSIS
  Create the Vivado project on Windows.

.DESCRIPTION
  Uses design name to create project.

.EXAMPLE
  .\create_project.ps1 -Design pynq_base_zux
#>

param(
  [string]$Design = "pynq_base_zux",
  [string]$Part = "",
  [switch]$Force,
  [string]$VivadoPath = "",
  [switch]$Verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$ProjectTcl = Join-Path $ScriptDir "tcl\project.tcl"

$ConfigFile = Join-Path $ProjectDir "designs\$Design\config.tcl"
if (-not (Test-Path $ConfigFile)) {
  throw "Design not found: designs\$Design"
}

if (-not (Test-Path $ProjectTcl)) {
  throw "Missing Tcl entrypoint: $ProjectTcl"
}

$VivadoVersion = "2024.2"
if (-not $VivadoPath) {
  $VivadoPath = Join-Path "C:\Xilinx\Vivado\$VivadoVersion\bin" "vivado.bat"
  if (-not (Test-Path $VivadoPath)) {
    if ($env:VIVADO_PATH -and (Test-Path $env:VIVADO_PATH)) {
      $VivadoPath = $env:VIVADO_PATH
    } else {
      throw "Vivado not found. Set VIVADO_PATH env var or use -VivadoPath"
    }
  }
}

Write-Host "========================================"
Write-Host "Vivado Project Builder"
Write-Host "========================================"
Write-Host ""
Write-Host "Design:     $Design"
Write-Host "Config:     $ConfigFile"
Write-Host "Vivado:      $VivadoPath"
Write-Host ""

$vivadoArgs = @(
  "-mode", "tcl",
  "-source", $ProjectTcl,
  "-tclargs",
  "-design", $Design
)

if ($Force) { $vivadoArgs += @("-force") }
if ($Part) { $vivadoArgs += @("-part", $Part) }
if ($Verbose) { $vivadoArgs += @("-verbose") }

& $VivadoPath @vivadoArgs
$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "Vivado exit code: $exitCode"

if ($exitCode -ne 0) {
  throw "[ERROR] Project creation failed."
}

Write-Host ""
Write-Host "[SUCCESS] Project created: build\$Design\$Design.xpr"
