<#
.SYNOPSIS
    Prime Utilities - Windows System Tweaks & Debloater Engine
.DESCRIPTION
    Applies performance, privacy, telemetry, and service tweaks safely to Windows 10/11.
#>

[CmdletBinding()]
param(
    [switch]$DisableTelemetry,
    [switch]$RemoveBloatware,
    [switch]$DisableCortana,
    [switch]$DisableBingSearch,
    [switch]$DisableGameDVR,
    [switch]$OptimizeServices,
    [switch]$DisableLocationTracking,
    [switch]$FixMouseAcceleration,
    [switch]$CreateRestorePoint,
    [string]$Preset = ""
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  PRIME UTILITIES - SYSTEM TWEAKS ENGINE  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check Administrator Elevation
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Caution: Prime Utilities is not running with Administrator privileges. Some registry/service tweaks may fail."
}

# Create System Restore Point if requested
if ($CreateRestorePoint) {
    Write-Host "`n[+] Creating System Restore Point..." -ForegroundColor Yellow
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Prime Utilities Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "  [SUCCESS] System Restore Point created successfully." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Failed to create System Restore Point: $_"
    }
}

# Apply Preset Configurations
if ($Preset -eq "Gaming" -or $Preset -eq "Advanced") {
    Write-Host "`n[+] Applying Preset: GAMING & ADVANCED OPTIMIZATION..." -ForegroundColor Magenta
    $DisableTelemetry = $true
    $DisableGameDVR = $true
    $DisableBingSearch = $true
    $OptimizeServices = $true
    $FixMouseAcceleration = $true
} elseif ($Preset -eq "Desktop" -or $Preset -eq "Standard") {
    Write-Host "`n[+] Applying Preset: STANDARD DESKTOP..." -ForegroundColor Magenta
    $DisableTelemetry = $true
    $DisableBingSearch = $true
    $RemoveBloatware = $true
} elseif ($Preset -eq "Laptop" -or $Preset -eq "Minimal") {
    Write-Host "`n[+] Applying Preset: MINIMAL / LAPTOP..." -ForegroundColor Magenta
    $DisableTelemetry = $true
    $DisableLocationTracking = $false
    $DisableCortana = $true
}

# 1. Disable Telemetry & Tracking
if ($DisableTelemetry) {
    Write-Host "`n[+] Disabling Windows Telemetry & Diagnostics..." -ForegroundColor DarkCyan
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        
        Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue
        Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
        
        Write-Host "  [OK] Telemetry services and registry flags disabled." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Could not fully disable telemetry: $_"
    }
}

# 2. Disable Bing Search in Start Menu
if ($DisableBingSearch) {
    Write-Host "`n[+] Disabling Bing Search in Start Menu..." -ForegroundColor DarkCyan
    try {
        $path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Bing Search in Start Menu disabled." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Could not disable Bing Search: $_"
    }
}

# 3. Disable GameDVR & Xbox Background Recording
if ($DisableGameDVR) {
    Write-Host "`n[+] Disabling GameDVR & Background Recording..." -ForegroundColor DarkCyan
    try {
        $path = "HKCU:\System\GameConfigStore"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "GameDVR_Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        
        $path2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        if (-not (Test-Path $path2)) { New-Item -Path $path2 -Force | Out-Null }
        Set-ItemProperty -Path $path2 -Name "AllowGameDVR" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] GameDVR disabled." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Could not disable GameDVR: $_"
    }
}

# 4. Remove Windows Appx Bloatware
if ($RemoveBloatware) {
    Write-Host "`n[+] Removing Common Windows Appx Bloatware..." -ForegroundColor DarkCyan
    $bloatApps = @(
        "Microsoft.3DBuilder",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.YourPhone",
        "Microsoft.ZuneVideo",
        "Microsoft.ZuneMusic"
    )
    foreach ($app in $bloatApps) {
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Write-Host "  [OK] Bloatware applications removed." -ForegroundColor Green
}

# 5. Disable Cortana
if ($DisableCortana) {
    Write-Host "`n[+] Disabling Cortana..." -ForegroundColor DarkCyan
    try {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "AllowCortana" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Cortana disabled." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Could not disable Cortana: $_"
    }
}

# 6. Optimize Windows Background Services
if ($OptimizeServices) {
    Write-Host "`n[+] Optimizing Non-Essential Background Services..." -ForegroundColor DarkCyan
    $servicesToManual = @(
        "MapsBroker",     # Downloaded Maps Manager
        "Fax",            # Fax service
        "XblAuthManager", # Xbox Live Auth (if not gaming)
        "XblGameSave"     # Xbox Live Save
    )
    foreach ($svc in $servicesToManual) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        }
    }
    Write-Host "  [OK] Unnecessary services switched to Manual startup." -ForegroundColor Green
}

# 7. Mouse Acceleration Fix
if ($FixMouseAcceleration) {
    Write-Host "`n[+] Disabling Mouse Acceleration (Enhanced Pointer Precision)..." -ForegroundColor DarkCyan
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Mouse Acceleration disabled for raw 1:1 precision." -ForegroundColor Green
    } catch {
        Write-Warning "  [WARN] Could not adjust mouse acceleration: $_"
    }
}

Write-Host "`n[COMPLETED] Selected tweaks have been successfully applied." -ForegroundColor Green
