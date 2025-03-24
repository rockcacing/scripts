#Requires -RunAsAdministrator 
#
#   Windows Setup Script
#
#   Usage:
#
#       iwr -useb https://raw.githubusercontent.com/rockcacing/scripts/setup_windows.ps1 | iex
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
$LOGFILE = "$PSScriptRoot\setup-windows.txt"
Start-Transcript -Path $LOGFILE -Append

Write-Output "Starting Windows setup at $(Get-Date)"

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
    "anydesk.install",
    "cygwin",
    "googlechrome",
    "microsoft-windows-terminal",
    "rustdesk",
    "sublimetext4",
    "syncthing",
    "tailscale"
)

foreach ($package in $packages) {
    if (-not (choco list --local-only | Select-String $package)) {
        Write-Output "Installing $package..."
        choco install $package -y
    } else {
        Write-Output "$package is already installed."
    }
}


# Append Cygwin\bin folder to environment PATH
$CygwinPath = "C:\tools\cygwin\bin"
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($CurrentPath -notlike "*${CygwinPath}*") {
    Write-Output "Adding Cygwin\bin to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$CygwinPath", [System.EnvironmentVariableTarget]::Machine)
    $env:Path += ";$CygwinPath"
}

# Validate Cygwin installation
if (Test-Path "$CygwinPath\bash.exe") {
    Write-Output "Cygwin installation validated successfully."
} else {
    Write-Output "Cygwin installation validation failed. Check the installation."
}

# Install File Browser
Write-Output "Installing File Browser..."
iwr -useb https://raw.githubusercontent.com/filebrowser/get/master/get.ps1 | iex

Write-Output "Setup completed at $(Get-Date)"
Stop-Transcript