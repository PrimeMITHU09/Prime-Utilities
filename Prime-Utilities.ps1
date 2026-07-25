<#
.SYNOPSIS
    Prime Utilities - Prime Mithu Tech Grand Terminal Launcher
.DESCRIPTION
    Extra large ASCII Art Header for PRIME MITHU TECH in PowerShell.
#>

[CmdletBinding()]
param(
    [switch]$WPF,
    [switch]$Web,
    [switch]$CLI
)

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

Clear-Host

Write-Host ""
Write-Host "  ########  ########  #### ##     ## ########" -ForegroundColor Magenta
Write-Host "  ##     ## ##     ##  ##  ###   ### ##      " -ForegroundColor Magenta
Write-Host "  ##     ## ##     ##  ##  #### #### ##      " -ForegroundColor Cyan
Write-Host "  ########  ########   ##  ## ### ## ######  " -ForegroundColor Cyan
Write-Host "  ##        ##   ##    ##  ##     ## ##      " -ForegroundColor Cyan
Write-Host "  ##        ##    ##   ##  ##     ## ##      " -ForegroundColor Magenta
Write-Host "  ##        ##     ## #### ##     ## ########" -ForegroundColor Magenta
Write-Host ""
Write-Host " ====================================================================" -ForegroundColor Cyan
Write-Host "        P R I M E   M I T H U   T E C H   U T I L I T I E S         " -ForegroundColor Yellow
Write-Host "             WINUTIL 1-TO-1 MASTER SYSTEM TOOLBOX                    " -ForegroundColor Green
Write-Host " ====================================================================" -ForegroundColor Cyan
Write-Host ""

# Default Launch Action: Native WPF Desktop GUI
if (-not $Web -and -not $CLI) {
    & "$PSScriptRoot\Prime-Utilities-WPF.ps1"
    exit 0
}

if ($Web) {
    Start-Process "$PSScriptRoot\index.html"
    exit 0
}
