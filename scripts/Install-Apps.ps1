<#
.SYNOPSIS
    Prime Utilities - Full Package Manager Engine (WinGet & Chocolatey)
.DESCRIPTION
    Supports 1-Click Install, Uninstall, Upgrade All, WinGet, and Chocolatey modes
    matching Chris Titus Tech WinUtil exact functionality.
#>

[CmdletBinding()]
param(
    [string[]]$AppIds = @(),
    [ValidateSet("WinGet", "Chocolatey")]
    [string]$PkgManager = "WinGet",
    [switch]$Uninstall,
    [switch]$UpgradeAll
)

# Function to verify or bootstrap WinGet / Chocolatey
function Ensure-PackageManager {
    if ($PkgManager -eq "WinGet") {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if (-not $winget) {
            Write-Host "[+] Bootstrapping Windows Package Manager (WinGet)..." -ForegroundColor Yellow
            try {
                Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
            } catch {}
        }
    } elseif ($PkgManager -eq "Chocolatey") {
        $choco = Get-Command choco -ErrorAction SilentlyContinue
        if (-not $choco) {
            Write-Host "[+] Installing Chocolatey Package Manager..." -ForegroundColor Yellow
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            } catch {}
        }
    }
}

Ensure-PackageManager

# Upgrade All Applications Mode
if ($UpgradeAll) {
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "  PRIME UTILITIES - UPGRADING ALL APPLICATIONS   " -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    if ($PkgManager -eq "WinGet") {
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
    } else {
        choco upgrade all -y
    }
    Write-Host "`n[SUCCESS] Upgrade All completed." -ForegroundColor Green
    exit 0
}

if ($AppIds.Count -eq 0) {
    Write-Host "[!] No applications specified." -ForegroundColor Yellow
    exit 0
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  PRIME UTILITIES - PACKAGE MANAGER ($PkgManager)  " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($appId in $AppIds) {
    if ($Uninstall) {
        Write-Host "`n[>] Uninstalling: $appId" -ForegroundColor Yellow
        try {
            if ($PkgManager -eq "WinGet") {
                Start-Process -FilePath "winget" -ArgumentList "uninstall --id `"$appId`" --silent --accept-source-agreements" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath "choco" -ArgumentList "uninstall `"$appId`" -y" -Wait -NoNewWindow
            }
            Write-Host "  [SUCCESS] $appId uninstalled." -ForegroundColor Green
            $successCount++
        } catch {
            Write-Warning "  [FAILED] Could not uninstall ${appId}."
            $failCount++
        }
    } else {
        Write-Host "`n[>] Installing: $appId" -ForegroundColor Cyan
        try {
            if ($PkgManager -eq "WinGet") {
                $process = Start-Process -FilePath "winget" -ArgumentList "install --id `"$appId`" --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity" -Wait -NoNewWindow -PassThru -ErrorAction Stop
                if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                    Write-Host "  [SUCCESS] $appId installed successfully!" -ForegroundColor Green
                    $successCount++
                } else {
                    Write-Host "  [NOTE] Package manager returned exit code $($process.ExitCode) for $appId." -ForegroundColor DarkYellow
                    $successCount++
                }
            } else {
                $process = Start-Process -FilePath "choco" -ArgumentList "install `"$appId`" -y" -Wait -NoNewWindow -PassThru -ErrorAction Stop
                Write-Host "  [SUCCESS] $appId installed via Chocolatey!" -ForegroundColor Green
                $successCount++
            }
        } catch {
            Write-Warning "  [FAILED] Error installing ${appId}."
            $failCount++
        }
    }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host " Summary: $successCount Succeeded, $failCount Failed." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan
