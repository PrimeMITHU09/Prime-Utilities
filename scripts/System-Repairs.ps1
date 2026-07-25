<#
.SYNOPSIS
    Prime Utilities - Windows Repair & System Diagnostics Engine
.DESCRIPTION
    Performs system file scans (SFC), image repairs (DISM), network stack resets, and DNS flushing.
#>

[CmdletBinding()]
param(
    [switch]$RunSFC,
    [switch]$RunDISM,
    [switch]$ResetNetwork,
    [switch]$FlushDNS,
    [switch]$ResetWindowsUpdateCache,
    [switch]$EnableWSL,
    [switch]$EnableHyperV
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  PRIME UTILITIES - SYSTEM REPAIRS ENGINE " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Flush DNS Cache
if ($FlushDNS) {
    Write-Host "`n[+] Flushing DNS Resolver Cache..." -ForegroundColor Yellow
    try {
        Clear-DnsClientCache
        Write-Host "  [SUCCESS] DNS Resolver Cache successfully flushed." -ForegroundColor Green
    } catch {
        ipconfig /flushdns
    }
}

# 2. Reset Network Stack (Winsock, IP Reset)
if ($ResetNetwork) {
    Write-Host "`n[+] Resetting Winsock & TCP/IP Stack..." -ForegroundColor Yellow
    try {
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        Write-Host "  [SUCCESS] Network stack reset complete. A system restart is recommended." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Error resetting network stack: $_"
    }
}

# 3. Reset Windows Update Cache
if ($ResetWindowsUpdateCache) {
    Write-Host "`n[+] Resetting Windows Update Components & Clearing SoftwareDistribution Cache..." -ForegroundColor Yellow
    try {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "cryptsvc" -Force -ErrorAction SilentlyContinue
        
        $sdPath = "$env:SystemRoot\SoftwareDistribution"
        if (Test-Path $sdPath) {
            Remove-Item -Path "$sdPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Start-Service -Name "bits" -ErrorAction SilentlyContinue
        Start-Service -Name "cryptsvc" -ErrorAction SilentlyContinue
        Write-Host "  [SUCCESS] Windows Update cache cleared and services restarted." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Error clearing Windows Update cache: $_"
    }
}

# 4. DISM Component Store Repair
if ($RunDISM) {
    Write-Host "`n[+] Running DISM Component Store Scan & Repair (RestoreHealth)..." -ForegroundColor Yellow
    try {
        dism.exe /Online /Cleanup-Image /RestoreHealth
        Write-Host "  [SUCCESS] DISM Repair process completed." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] DISM Repair encountered an error: $_"
    }
}

# 5. SFC System File Checker
if ($RunSFC) {
    Write-Host "`n[+] Running System File Checker (SFC /scannow)..." -ForegroundColor Yellow
    try {
        sfc.exe /scannow
        Write-Host "  [SUCCESS] SFC System scan completed." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] SFC scan encountered an error: $_"
    }
}

# 6. Optional Windows Features (WSL / Hyper-V)
if ($EnableWSL) {
    Write-Host "`n[+] Enabling Windows Subsystem for Linux (WSL)..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -ErrorAction SilentlyContinue
    Write-Host "  [SUCCESS] WSL feature enabled." -ForegroundColor Green
}

if ($EnableHyperV) {
    Write-Host "`n[+] Enabling Hyper-V Platform..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -ErrorAction SilentlyContinue
    Write-Host "  [SUCCESS] Hyper-V platform enabled." -ForegroundColor Green
}

Write-Host "`n[COMPLETED] System repairs and configurations finished." -ForegroundColor Green
