#Requires -RunAsAdministrator 
#
#   Workstation Setup Script
#
#   Usage:
#
#       iwr -useb https://raw.githubusercontent.com/rockcacing/scripts/setup_workstation.ps1 | iex
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

Write-Output "Starting Workstation setup at $(Get-Date)"

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
    "caddy",
    "mariadb",
    "notion",
    "postman",
    "sqlyog",
    "telegram",
    "termius",
    "vscode",
    "WhatsApp",
    "winrar"
)

foreach ($package in $packages) {
    if (-not (choco list --local-only | Select-String $package)) {
        Write-Output "Installing $package..."
        choco install $package -y
    } else {
        Write-Output "$package is already installed."
    }
}

# Install specific versions of Node.js and Python
Write-Output "Installing Node.js v20.11.0..."
choco install -y nodejs --version=20.11.0

Write-Output "Installing Python v3.10.5..."
choco install -y python3 --version=3.10.5

# Install global npm packages
Write-Output "Installing global npm packages..."
npm i -g nodemon pm2 pm2-windows-startup

# Configure PM2 startup
Write-Output "Configuring PM2 startup..."
pm2-startup install

Write-Output "Setup completed at $(Get-Date)"
Stop-Transcript