<#
.SYNOPSIS
    Prime Utilities - Windows Update Policy Manager
.DESCRIPTION
    Configures Windows Update behaviors (Recommended, Default, Disable Updates, Deferral).
#>

[CmdletBinding()]
param(
    [ValidateSet("Recommended", "Default", "Reset", "Disable", "SecurityOnly", "Pause", "Delay")]
    [string]$Mode = "Recommended"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  PRIME UTILITIES - WINDOWS UPDATE MANAGER" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$auKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$wuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (-not (Test-Path $auKey)) { New-Item -Path $auKey -Force | Out-Null }
if (-not (Test-Path $wuKey)) { New-Item -Path $wuKey -Force | Out-Null }

switch ($Mode) {
    "Recommended" {
        Write-Host "`n[+] Applying RECOMMENDED Windows Update Profile..." -ForegroundColor Yellow
        try {
            # Defer feature updates for 365 days
            Set-ItemProperty -Path $wuKey -Name "DeferFeatureUpdates" -Type DWord -Value 1 -Force
            Set-ItemProperty -Path $wuKey -Name "DeferFeatureUpdatesPeriodInDays" -Type DWord -Value 365 -Force
            
            # Defer quality updates for 4 days
            Set-ItemProperty -Path $wuKey -Name "DeferQualityUpdates" -Type DWord -Value 1 -Force
            Set-ItemProperty -Path $wuKey -Name "DeferQualityUpdatesPeriodInDays" -Type DWord -Value 4 -Force
            
            # Exclude drivers in quality updates
            Set-ItemProperty -Path $wuKey -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1 -Force
            
            # Prevent automatic restarts while user is signed in
            Set-ItemProperty -Path $auKey -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1 -Force
            Set-ItemProperty -Path $auKey -Name "AUOptions" -Type DWord -Value 3 -Force
            
            Write-Host "  [SUCCESS] Recommended Windows Update profile applied cleanly." -ForegroundColor Green
        } catch {
            Write-Warning "  [WARN] Failed to set recommended policies: $_"
        }
    }
    
    { $_ -in @("Default", "Reset") } {
        Write-Host "`n[+] Restoring DEFAULT Windows Update Settings..." -ForegroundColor Yellow
        try {
            Remove-ItemProperty -Path $auKey -Name "AUOptions" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $auKey -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $auKey -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $wuKey -Name "DeferFeatureUpdates" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $wuKey -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $wuKey -Name "DeferQualityUpdates" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $wuKey -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $wuKey -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
            
            Set-Service -Name "wuauserv" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
            Set-Service -Name "bits" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "bits" -ErrorAction SilentlyContinue
            
            Write-Host "  [SUCCESS] Windows Update returned to default automatic operation." -ForegroundColor Green
        } catch {
            Write-Warning "  [WARN] Could not restore defaults: $_"
        }
    }
    
    "Disable" {
        Write-Host "`n[+] DISABLING Windows Updates (Advanced Use Only)..." -ForegroundColor Red
        try {
            Set-ItemProperty -Path $auKey -Name "NoAutoUpdate" -Type DWord -Value 1 -Force
            
            Stop-Service -Name "wuauserv" -ErrorAction SilentlyContinue
            Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name "bits" -ErrorAction SilentlyContinue
            Set-Service -Name "bits" -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name "dosvc" -ErrorAction SilentlyContinue
            Set-Service -Name "dosvc" -StartupType Disabled -ErrorAction SilentlyContinue
            
            Write-Host "  [SUCCESS] Automatic Windows Updates disabled." -ForegroundColor Green
        } catch {
            Write-Warning "  [WARN] Could not disable update services: $_"
        }
    }
}

Write-Host "`n[COMPLETED] Windows Update configuration updated." -ForegroundColor Green
