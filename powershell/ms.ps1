# Forensic Analysis Script for Windows Host

# Requires running as an Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges." -ForegroundColor Red
    Exit
}

# Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Create Output Directory
$OutputDir = "$env:USERPROFILE\Desktop\Forensic_Report_" + (Get-Date -Format "yyyyMMdd_HHmmss")
mkdir $OutputDir

# System Information Collection
function Get-SystemInfo {
    Write-Host "Collecting System Information..." -ForegroundColor Green
    Get-ComputerInfo | Out-File "$OutputDir\SystemInfo.txt"
}

# User Accounts Information
function Get-UserAccounts {
    Write-Host "Collecting User Account Information..." -ForegroundColor Green
    Get-LocalUser | Select-Object Name,Enabled,LastLogon | Out-File "$OutputDir\UserAccounts.txt"
}

# Security Logs
function Get-SecurityLogs {
    Write-Host "Collecting Security Logs..." -ForegroundColor Green
    Get-EventLog -LogName Security -Newest 1000 | Out-File "$OutputDir\SecurityLogs.txt"
}

# Network Information
function Get-NetworkInfo {
    Write-Host "Collecting Network Information..." -ForegroundColor Green
    Get-NetTCPConnection | Out-File "$OutputDir\NetworkConnections.txt"
    Get-NetIPAddress | Out-File "$OutputDir\NetworkIPAddresses.txt" -Append
}

# Processes and Services
function Get-ProcessesAndServices {
    Write-Host "Collecting Processes and Services Information..." -ForegroundColor Green
    Get-Process | Out-File "$OutputDir\Processes.txt"
    Get-Service | Out-File "$OutputDir\Services.txt"
}

# Installed Programs
function Get-InstalledPrograms {
    Write-Host "Collecting Installed Programs Information..." -ForegroundColor Green
    Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Out-File "$OutputDir\InstalledPrograms.txt"
}

# Registry Information
function Get-RegistryInfo {
    Write-Host "Collecting Registry Information..." -ForegroundColor Green
    # Example: Export a specific registry key
    reg export HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall "$OutputDir\UninstallKey.reg"
}

# Running Functions
Get-SystemInfo
Get-UserAccounts
Get-SecurityLogs
Get-NetworkInfo
Get-ProcessesAndServices
Get-InstalledPrograms
Get-RegistryInfo

Write-Host "Forensic data collection complete. Check the Desktop for the report folder." -ForegroundColor Green