#Requires -RunAsAdministrator 
#
#   Others Setup Script
#
#   Usage:
#
#       iwr -useb https://raw.githubusercontent.com/rockcacing/scripts/setup_others.ps1 | iex
#
#   You should run it as administrator so it can add filemanager to 
#   the PATH.
#

# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as Administrator. Exiting..."
    Exit 1
}

# Log File
$LOGFILE = "$PSScriptRoot\setup-workstation.txt"
Start-Transcript -Path $LOGFILE -Append

Write-Output "Starting Others setup at $(Get-Date)"

# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    refreshenv
}

# Install required software using Chocolatey
$packages = @(
    "Everything",
    "flameshot",
    "filezilla",
    "filezilla.server",
    "responsively",
    "teamviewer",
    "zoom"
)

foreach ($package in $packages) {
    if (-not (choco list --local-only | Select-String $package)) {
        Write-Output "Installing $package..."
        choco install $package -y
    } else {
        Write-Output "$package is already installed."
    }
}

Write-Output "Setup completed at $(Get-Date)"
Stop-Transcript