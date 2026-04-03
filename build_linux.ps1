<#
.SYNOPSIS
    Build SST for Linux (Release) via WSL Ubuntu.

.DESCRIPTION
    Thin PowerShell wrapper that launches build_linux.sh inside WSL Ubuntu.
    All actual build logic lives in build_linux.sh.

.PARAMETER Clean
    Remove the build directory before building.

.PARAMETER SkipDeps
    Skip the dependency installation check.

.PARAMETER Package
    Run CPack after building to create a .tar.gz archive.

.EXAMPLE
    .\build_linux.ps1
    .\build_linux.ps1 -Clean
    .\build_linux.ps1 -Clean -Package
#>
param(
    [switch]$Clean,
    [switch]$SkipDeps,
    [switch]$Package
)

$ErrorActionPreference = "Stop"

# Convert this script's directory to a WSL path
$WinDir  = $PSScriptRoot
$WslPath = $WinDir -replace '\\', '/'
$WslDir  = (wsl -d Ubuntu -- wslpath "'$WslPath'") | Select-Object -Last 1
$WslDir  = $WslDir.Trim()
$ShellScript = "$WslDir/build_linux.sh"

# Build argument list
$args_list = @()
if ($Clean)    { $args_list += "--clean" }
if ($SkipDeps) { $args_list += "--skip-deps" }
if ($Package)  { $args_list += "--package" }

$argString = $args_list -join " "

Write-Host "Launching WSL Ubuntu build..." -ForegroundColor Cyan
Write-Host "  Script: $ShellScript $argString" -ForegroundColor Gray
Write-Host ""

# Run the bash script inside WSL
wsl -d Ubuntu -- bash "$ShellScript" $args_list

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build FAILED (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
