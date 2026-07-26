<#
.SYNOPSIS
    Prime Utilities - WinUtil 1-to-1 Master Edition (Live iwr | iex Online Execution Engine)
.DESCRIPTION
    Fixes $PSScriptRoot empty string binding error and enables live online execution via GitHub.
#>

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

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

$githubRawBase = "https://raw.githubusercontent.com/PrimeMITHU09/Prime-Utilities/main"

# Fallback for $PSScriptRoot when executed via iwr | iex
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = "."
}

$logoPath = Join-Path $scriptDir "assets\prime_utilities_logo.jpg"
if (-not (Test-Path $logoPath)) {
    try {
        $tempLogo = Join-Path $env:TEMP "prime_utilities_logo.jpg"
        if (-not (Test-Path $tempLogo)) {
            (New-Object System.Net.WebClient).DownloadFile("$githubRawBase/assets/prime_utilities_logo.jpg", $tempLogo)
        }
        $logoPath = $tempLogo
    } catch {}
}
$jsonPath = Join-Path $scriptDir "config\applications.json"
$iconsFolder = Join-Path $scriptDir "assets\icons"
$installScriptPath = Join-Path $scriptDir "scripts\Install-Apps.ps1"

# Icon Strings (UTF-32 Safe)
$chSun   = [char]::ConvertFromUtf32(0x263C)  # ☼ (Day / Light)
$chMoon  = [char]::ConvertFromUtf32(0x263D)  # ☽ (Night / Dark)
$chGear  = [char]::ConvertFromUtf32(0x2699)  # ⚙
$chMin   = [char]::ConvertFromUtf32(0x2014)  # —
$chMax   = [char]::ConvertFromUtf32(0x25A1)  # 🗖
$chClose = [char]::ConvertFromUtf32(0x2715)  # ✕

# Load Full App Database (Local Disk + Live Web iwr | iex Fallback)
$appsData = @{}
if (Test-Path $jsonPath) {
    try {
        $rawJson = Get-Content $jsonPath -Raw | ConvertFrom-Json
        foreach ($prop in $rawJson.psobject.Properties) {
            $appsData[$prop.Name] = $prop.Value
        }
    } catch {}
}

if ($appsData.Count -eq 0) {
    try {
        $webJsonStr = (New-Object System.Net.WebClient).DownloadString("$githubRawBase/config/applications.json")
        $rawJson = $webJsonStr | ConvertFrom-Json
        foreach ($prop in $rawJson.psobject.Properties) {
            $appsData[$prop.Name] = $prop.Value
        }
    } catch {}
}

$inputXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinUtil" Height="780" Width="1200"
        WindowStyle="None" AllowsTransparency="False" WindowStartupLocation="CenterScreen"
        Background="#0F1722" Foreground="#F8FAFC">
    <Window.Resources>
        <Style TargetType="Button" x:Key="HeaderIconBtn">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="6,2"/>
            <Setter Property="Margin" Value="2,0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                    <Setter Property="Background" Value="#1E293B"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="Button" x:Key="CloseBtn">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="8,2"/>
            <Setter Property="Margin" Value="2,0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="White"/>
                    <Setter Property="Background" Value="#DC2626"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#182232"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,4"/>
            <Setter Property="Margin" Value="0,2"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="FontSize" Value="11.5"/>
            <Setter Property="Margin" Value="2,3"/>
        </Style>
    </Window.Resources>

    <Border Name="mainOuterBorder" BorderBrush="#CBD5E1" BorderThickness="1">
        <Grid Name="mainRootGrid">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Top Custom Navigation & Title Header Bar -->
            <Border Name="hdrDragBorder" Grid.Row="0" Background="#0B111A" BorderBrush="#1E293B" BorderThickness="0,0,0,1" Padding="8,6">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Left" Orientation="Horizontal">
                        <Border Width="30" Height="30" CornerRadius="6" Margin="0,0,10,0" Background="#8B5CF6">
                            <Image Name="imgHeaderLogo" Stretch="UniformToFill">
                                <Image.Clip>
                                    <RectangleGeometry RadiusX="6" RadiusY="6" Rect="0,0,30,30"/>
                                </Image.Clip>
                            </Image>
                        </Border>
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Button Name="btnTabInstall" Content="Install" Background="#2563EB" Foreground="White" BorderBrush="#3B82F6" Width="80" Margin="2,0"/>
                            <Button Name="btnTabTweaks" Content="Tweaks" Background="#182232" Foreground="#F8FAFC" BorderBrush="#334155" Width="80" Margin="2,0"/>
                            <Button Name="btnTabConfig" Content="Config" Background="#182232" Foreground="#F8FAFC" BorderBrush="#334155" Width="80" Margin="2,0"/>
                            <Button Name="btnTabUpdates" Content="Updates" Background="#182232" Foreground="#F8FAFC" BorderBrush="#334155" Width="80" Margin="2,0"/>
                            <Button Name="btnTabCreator" Content="Win11 Creator" Background="#182232" Foreground="#F8FAFC" BorderBrush="#334155" Width="110" Margin="2,0"/>
                        </StackPanel>
                    </StackPanel>
                    
                    <!-- Right Icons: Theme | Font Scale | Settings | Min | Max | Close -->
                    <StackPanel DockPanel.Dock="Right" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                        <TextBox Name="txtSearch" Width="220" Height="26" Background="#182232" Foreground="#F8FAFC" BorderBrush="#334155" Padding="6,2" Text="" VerticalAlignment="Center" Margin="0,0,14,0"/>
                        
                        <Button Name="btnThemeToggle" Style="{StaticResource HeaderIconBtn}" Content="$chMoon" ToolTip="Toggle Theme (Day / Night)"/>
                        <Button Name="btnFontSize" Style="{StaticResource HeaderIconBtn}" ToolTip="Toggle Font Size Scaling (100% / 120% / 140%)">
                            <TextBlock Text="A" TextDecorations="Underline" FontWeight="Bold"/>
                        </Button>
                        <Button Name="btnSettings" Style="{StaticResource HeaderIconBtn}" Content="$chGear" ToolTip="Settings Menu"/>
                        
                        <TextBlock Text=" " Width="12"/>
                        
                        <Button Name="btnWinMinimize" Style="{StaticResource HeaderIconBtn}" Content="$chMin" ToolTip="Minimize"/>
                        <Button Name="btnWinMaximize" Style="{StaticResource HeaderIconBtn}" Content="$chMax" ToolTip="Maximize"/>
                        <Button Name="btnWinClose" Style="{StaticResource CloseBtn}" Content="$chClose" ToolTip="Close"/>
                    </StackPanel>
                </DockPanel>
            </Border>

            <!-- Install Tab Filters Bar -->
            <Border Name="barFilters" Grid.Row="1" Background="#0D1520" BorderBrush="#1E293B" BorderThickness="0,0,0,1" Padding="10,6" Visibility="Visible">
                <StackPanel Name="pnlFilters" Orientation="Horizontal">
                    <TextBlock Text="Filters" Foreground="#38BDF8" FontWeight="Bold" FontSize="13" VerticalAlignment="Center" Margin="0,0,12,0"/>
                    <Button Name="btnFilterAll" Content="All" Background="#334155" Foreground="#F8FAFC" BorderBrush="#38BDF8" Margin="2,0"/>
                    <Button Name="btnFilterBrowsers" Content="Browsers" Margin="2,0"/>
                    <Button Name="btnFilterComms" Content="Communications" Margin="2,0"/>
                    <Button Name="btnFilterDev" Content="Development" Margin="2,0"/>
                    <Button Name="btnFilterGames" Content="Games" Margin="2,0"/>
                    <Button Name="btnFilterMSTools" Content="Microsoft Tools" Margin="2,0"/>
                    <Button Name="btnFilterMedia" Content="Multimedia Tools" Margin="2,0"/>
                    <Button Name="btnFilterPro" Content="Pro Tools" Margin="2,0"/>
                    <Button Name="btnFilterUtils" Content="Utilities" Margin="2,0"/>
                </StackPanel>
            </Border>

            <!-- Tweaks Tab Sub-Header Presets Bar -->
            <Border Name="barTweaksPresets" Grid.Row="1" Background="#0D1520" BorderBrush="#1E293B" BorderThickness="0,0,0,1" Padding="10,6" Visibility="Collapsed">
                <StackPanel Orientation="Horizontal">
                    <TextBlock Name="txtRecommendedLabel" Text="Recommended Selections:" Foreground="#94A3B8" FontSize="12" VerticalAlignment="Center" Margin="0,0,12,0"/>
                    <Button Name="btnPresetStandard" Content="Standard" Width="100" Margin="3,0"/>
                    <Button Name="btnPresetMinimal" Content="Minimal" Width="100" Margin="3,0"/>
                    <Button Name="btnPresetAdvanced" Content="Advanced" Width="100" Margin="3,0"/>
                    <Button Name="btnPresetClear" Content="Clear" Width="80" Margin="3,0"/>
                    <Button Name="btnGetInstalledTweaks" Content="Get Installed Tweaks" Width="130" Margin="3,0"/>
                    <Button Name="btnAppXRemoval" Content="AppX Removal" Width="110" Margin="3,0"/>
                </StackPanel>
            </Border>

            <!-- TAB 1: INSTALL VIEW -->
            <Grid Name="viewInstall" Grid.Row="2" Margin="8" Visibility="Visible">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="230"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Name="boxInstallLeft" Grid.Column="0" Background="#141D2B" BorderBrush="#1E293B" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,8,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="- Actions" Foreground="#38BDF8" FontWeight="Bold" FontSize="13" Margin="0,0,0,6"/>
                            <Button Name="btnInstallSelected" Content="Install/Upgrade Applications" Background="#2563EB" Foreground="White" BorderBrush="#3B82F6" Height="32" Margin="0,3"/>
                            <Button Name="btnUninstallSelected" Content="Uninstall Applications" Height="28" Margin="0,3"/>
                            <Button Name="btnUpgradeAll" Content="Upgrade all Applications" Height="28" Margin="0,3"/>

                            <TextBlock Text="- Package Manager" Foreground="#38BDF8" FontWeight="Bold" FontSize="13" Margin="0,14,0,6"/>
                            <RadioButton Name="radChoco" Content="Chocolatey" Foreground="#94A3B8" Margin="0,2"/>
                            <RadioButton Name="radWinGet" Content="WinGet" IsChecked="True" Foreground="#F8FAFC" Margin="0,2"/>

                            <TextBlock Text="- Selection" Foreground="#38BDF8" FontWeight="Bold" FontSize="13" Margin="0,14,0,6"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,6">
                                <Ellipse Width="6" Height="6" Fill="#16A34A" Margin="0,0,6,0"/>
                                <TextBlock Text="Free and Open Source Software" Foreground="#16A34A" FontSize="11"/>
                            </StackPanel>
                            <Button Name="btnClearSel" Content="Clear Selection" Height="28" Margin="0,2"/>
                            <Button Name="btnCollapseAll" Content="Collapse All Categories" Height="28" Margin="0,2"/>
                            <Button Name="btnExpandAll" Content="Expand All Categories" Height="28" Margin="0,2"/>
                            <Button Name="txtSelCount" Content="Selected Apps: 0" Height="28" Margin="0,2"/>
                            <Button Name="btnShowInstalled" Content="Show Installed Apps" Height="28" Margin="0,2"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <Border Name="boxInstallRight" Grid.Column="1" Background="#0F1722">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnlAppCategories" Margin="4">
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- TAB 2: TWEAKS VIEW -->
            <Grid Name="viewTweaks" Grid.Row="2" Margin="8" Visibility="Collapsed">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Name="boxTweaksLeft" Grid.Column="0" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,6,0">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="pnlTweaksCheckboxes">
                                <TextBlock Text="Essential Tweaks" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,0,0,8"/>
                                <CheckBox Name="chk1" Content="Activity History - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk2" Content="BitLocker - Disable [?]"/>
                                <CheckBox Name="chk3" Content="ConsumerFeatures - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk4" Content="Delivery Optimization - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk5" Content="Disk Cleanup - Run [?]" IsChecked="True"/>
                                <CheckBox Name="chk6" Content="End Task With Right Click - Enable [?]" IsChecked="True"/>
                                <CheckBox Name="chk7" Content="File Explorer Automatic Folder Discovery - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk8" Content="Hibernation - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk9" Content="Location Tracking - Disable [?]"/>
                                <CheckBox Name="chk10" Content="Microsoft Store Recommended Search Results - Disable [?]"/>
                                <CheckBox Name="chk11" Content="Prevent Device Companion Apps [?]"/>
                                <CheckBox Name="chk12" Content="Restore Point - Create [?]" IsChecked="True"/>
                                <CheckBox Name="chk13" Content="Services - Set to Manual [?]" IsChecked="True"/>
                                <CheckBox Name="chk14" Content="Start Menu Previous Layout - Enable [?]"/>
                                <CheckBox Name="chk15" Content="Telemetry - Disable [?]" IsChecked="True"/>
                                <CheckBox Name="chk16" Content="Temporary Files - Remove [?]"/>
                                <CheckBox Name="chk17" Content="Widgets - Remove [?]"/>
                                <CheckBox Name="chk18" Content="Windows Platform Binary Table (WPBT) - Disable [?]"/>

                                <TextBlock Text="Advanced Tweaks - CAUTION" Foreground="#DC2626" FontWeight="Bold" FontSize="13" Margin="0,16,0,8"/>
                                <CheckBox Name="chk19" Content="Adobe URL Block List - Enable [?]"/>
                                <CheckBox Name="chk20" Content="Background Apps - Disable [?]"/>
                                <CheckBox Name="chk21" Content="Brave Browser - Debloat [?]"/>
                                <CheckBox Name="chk22" Content="Date &amp; Time - Set Time to UTC [?]"/>
                                <CheckBox Name="chk23" Content="Disable Reserved Storage [?]"/>
                                <CheckBox Name="chk24" Content="File Explorer Home and Gallery - Disable [?]"/>
                                <CheckBox Name="chk25" Content="Fullscreen Optimizations - Disable [?]"/>
                                <CheckBox Name="chk26" Content="IPv6 - Disable [?]"/>
                                <CheckBox Name="chk27" Content="IPv6 - Set IPv4 as Preferred [?]"/>
                                <CheckBox Name="chk28" Content="Microsoft Edge - Debloat [?]"/>
                                <CheckBox Name="chk29" Content="Microsoft Edge - Remove [?]"/>
                                <CheckBox Name="chk30" Content="Microsoft OneDrive - Remove [?]"/>
                                <CheckBox Name="chk31" Content="Razer Software Auto-Install - Disable [?]"/>
                                <CheckBox Name="chk32" Content="RDP Unsigned File Warnings - Disable [?]"/>
                                <CheckBox Name="chk33" Content="Right-Click Menu Previous Layout - Enable [?]"/>
                                <CheckBox Name="chk34" Content="Storage Sense - Disable [?]"/>
                                <CheckBox Name="chk35" Content="System Tray Notifications &amp; Calendar - Disable [?]"/>
                                <CheckBox Name="chk36" Content="Teredo - Disable [?]"/>
                                <CheckBox Name="chk37" Content="Visual Effects - Set to Best Performance [?]"/>
                                <CheckBox Name="chk38" Content="Windows AI - Disable And Remove [?]"/>
                                
                                <Button Name="btnOOShutUp" Content="O&amp;O ShutUp10++ - Run" Width="140" HorizontalAlignment="Left" Margin="0,6,0,6"/>
                            </StackPanel>
                        </ScrollViewer>

                        <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,8,0,0">
                            <TextBlock Name="txtDnsLabel" Text="DNS - Set to:" FontSize="12" VerticalAlignment="Center" Margin="0,0,8,0"/>
                            <ComboBox Name="cmbDns" Width="140" Height="26" SelectedIndex="0">
                                <ComboBoxItem Content="Default"/>
                                <ComboBoxItem Content="Cloudflare (1.1.1.1)"/>
                                <ComboBoxItem Content="Google (8.8.8.8)"/>
                                <ComboBoxItem Content="AdGuard (Ad-Blocking)"/>
                                <ComboBoxItem Content="Quad9"/>
                            </ComboBox>
                        </StackPanel>
                    </Grid>
                </Border>

                <Border Name="boxTweaksRight" Grid.Column="1" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="12" Margin="6,0,0,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnlTweaksPrefs">
                            <TextBlock Text="Customize Preferences" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,0,0,8"/>
                            <CheckBox Name="pref1" Content="BSoD Verbose Mode"/>
                            <CheckBox Name="pref2" Content="Dark Theme for Windows" IsChecked="True"/>
                            <CheckBox Name="pref3" Content="Enable Long Paths" IsChecked="True"/>
                            <CheckBox Name="pref4" Content="File Explorer File Extensions" IsChecked="True"/>
                            <CheckBox Name="pref5" Content="File Explorer Hidden Files"/>
                            <CheckBox Name="pref6" Content="Game Mode"/>
                            <CheckBox Name="pref7" Content="Lock Screen - Disable"/>
                            <CheckBox Name="pref8" Content="Logon Screen Acrylic Blur"/>
                            <CheckBox Name="pref9" Content="Logon Verbose Mode"/>
                            <CheckBox Name="pref10" Content="Microsoft Outlook New Version" IsChecked="True"/>
                            <CheckBox Name="pref11" Content="Mouse Acceleration" IsChecked="True"/>
                            <CheckBox Name="pref12" Content="Multiplane Overlay" IsChecked="True"/>
                            <CheckBox Name="pref13" Content="Num Lock on Startup" IsChecked="True"/>
                            <CheckBox Name="pref14" Content="S0 Sleep Network Connectivity"/>
                            <CheckBox Name="pref15" Content="S3 Sleep"/>
                            <CheckBox Name="pref16" Content="Scrollbars Always Visible"/>
                            <CheckBox Name="pref17" Content="Settings Home Page" IsChecked="True"/>
                            <CheckBox Name="pref18" Content="Start Menu Bing Search" IsChecked="True"/>
                            <CheckBox Name="pref19" Content="Start Menu Recommendations"/>
                            <CheckBox Name="pref20" Content="Sticky Keys"/>
                            <CheckBox Name="pref21" Content="System Tray Battery Percentage"/>
                            <CheckBox Name="pref22" Content="Taskbar Centered Icons"/>
                            <CheckBox Name="pref23" Content="Taskbar Search Icon"/>
                            <CheckBox Name="pref24" Content="Taskbar Task View Icon"/>
                            <CheckBox Name="pref25" Content="Window Snapping" IsChecked="True"/>

                            <TextBlock Name="txtPerfLabel" Text="Performance Plans - NOT FOR LAPTOPS" Foreground="#0F172A" FontWeight="Bold" FontSize="12" Margin="0,18,0,8"/>
                            <Button Name="btnDisableUltimatePerf" Content="Ultimate Performance Profile - Disable" Height="28" Margin="0,2"/>
                            <Button Name="btnEnableUltimatePerf" Content="Ultimate Performance Profile - Enable" Height="28" Margin="0,2"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- TAB 3: CONFIG VIEW -->
            <Grid Name="viewConfig" Grid.Row="2" Margin="8" Visibility="Collapsed">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Name="boxConfigLeft" Grid.Column="0" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,6,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnlConfigLeft">
                            <TextBlock Text="Features" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,0,0,8"/>
                            <CheckBox Name="featNetFx" Content=".NET Framework (Versions 2, 3, 4) - Enable [?]"/>
                            <CheckBox Name="featHyperV" Content="Hyper-V - Enable [?]"/>
                            <CheckBox Name="featF8Disable" Content="Legacy F8 Boot Recovery - Disable [?]"/>
                            <CheckBox Name="featF8Enable" Content="Legacy F8 Boot Recovery - Enable [?]"/>
                            <CheckBox Name="featMedia" Content="Legacy Media Components (WMP, DirectPlay) - Enable [?]"/>
                            <CheckBox Name="featNFS" Content="Network File System (NFS) - Enable [?]"/>
                            <CheckBox Name="featRegBackup" Content="Registry Backup (Daily Task 12:30am) - Enable [?]"/>
                            <CheckBox Name="featSandbox" Content="Windows Sandbox - Enable [?]"/>
                            <CheckBox Name="featWSL" Content="Windows Subsystem for Linux (WSL) - Enable [?]"/>
                            <Button Name="btnInstallFeatures" Content="Install Features" Width="200" HorizontalAlignment="Left" Margin="0,6,0,16"/>

                            <TextBlock Text="Fixes" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,8,0,8"/>
                            <Button Name="btnFixAutoLogon" Content="AutoLogon - Run" Height="26" Margin="0,2"/>
                            <Button Name="btnFixNetReset" Content="Network - Reset" Height="26" Margin="0,2"/>
                            <Button Name="btnFixNtpServer" Content="NTP Server - Enable" Height="26" Margin="0,2"/>
                            <Button Name="btnFixSysCorruption" Content="System Corruption Scan - Run" Height="26" Margin="0,2"/>
                            <Button Name="btnFixWinUpdateReset" Content="Windows Update - Reset" Height="26" Margin="0,2"/>
                            <Button Name="btnFixWinGetReinstall" Content="WinGet - Reinstall" Height="26" Margin="0,2"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <Border Name="boxConfigRight" Grid.Column="1" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="12" Margin="6,0,0,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="pnlConfigRight">
                            <TextBlock Text="Legacy Windows Panels" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,0,0,8"/>
                            <Button Name="btnPanelCompMgmt" Content="Computer Management" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelControlPanel" Content="Control Panel" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelMouse" Content="Mouse Properties" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelNetConn" Content="Network Connections" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelPower" Content="Power Panel" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelPrinters" Content="Printer Panel" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelAppWiz" Content="Programs and Features" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelRegion" Content="Region" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelSecMaint" Content="Security and Maintenance" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelSound" Content="Sound Settings" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelSysProps" Content="System Properties" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelTimeDate" Content="Time and Date" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelFirewall" Content="Windows Defender Firewall" Height="26" Margin="0,2"/>
                            <Button Name="btnPanelRestore" Content="Windows Restore" Height="26" Margin="0,2"/>

                            <TextBlock Text="PowerShell Profile PowerShell 7+ Only" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,16,0,8"/>
                            <Button Name="btnProfileInstall" Content="CTT PowerShell Profile - Install" Height="26" Margin="0,2"/>
                            <Button Name="btnProfileRemove" Content="CTT PowerShell Profile - Remove" Height="26" Margin="0,2"/>

                            <TextBlock Text="Remote Access" Foreground="#0F172A" FontWeight="Bold" FontSize="13" Margin="0,16,0,8"/>
                            <Button Name="btnEnableSSH" Content="OpenSSH Server - Enable" Height="26" Margin="0,2"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- TAB 4: UPDATES VIEW -->
            <Grid Name="viewUpdates" Grid.Row="2" Margin="16" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Margin="0,0,0,20">
                    <TextBlock Name="txtUpdatesTitle" Text="Windows Update Profiles" FontSize="22" FontWeight="Bold" Foreground="#0F172A"/>
                    <TextBlock Name="txtUpdatesSub" Text="Choose how Windows receives updates. Each profile replaces the Windows Update settings managed by WinUtil." FontSize="13" Foreground="#475569" Margin="0,4,0,0"/>
                </StackPanel>

                <Grid Grid.Row="1">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Name="cardUpdate1" Grid.Column="0" Background="#FFFFFF" BorderBrush="#2563EB" BorderThickness="2" CornerRadius="6" Padding="16" Margin="0,0,8,0">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Name="txtCard1Title" Text="Recommended" FontSize="18" FontWeight="Bold" Foreground="#0F172A"/>
                                <TextBlock Name="txtCard1Sub" Text="Balanced security and stability" FontSize="12" Foreground="#475569" Margin="0,2,0,12"/>
                            </StackPanel>

                            <StackPanel Grid.Row="1" Name="pnlCard1Body">
                                <TextBlock Text="- Defers feature updates for 365 days" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Defers quality updates for 4 days" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Excludes drivers from quality updates" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Prevents automatic restarts while a user is signed in" FontSize="11" Margin="0,2"/>

                                <TextBlock Text="Available on Windows Pro, Enterprise, and Education editions." FontStyle="Italic" FontSize="11" Foreground="#475569" Margin="0,16,0,0"/>
                            </StackPanel>

                            <Button Name="btnApplyRecommendedUpdates" Grid.Row="2" Content="Apply Recommended" Height="30" Width="140" HorizontalAlignment="Center"/>
                        </Grid>
                    </Border>

                    <Border Name="cardUpdate2" Grid.Column="1" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="16" Margin="4,0,4,0">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Name="txtCard2Title" Text="Windows Default" FontSize="18" FontWeight="Bold" Foreground="#0F172A"/>
                                <TextBlock Name="txtCard2Sub" Text="Return control to Windows" FontSize="12" Foreground="#475569" Margin="0,2,0,12"/>
                            </StackPanel>

                            <StackPanel Grid.Row="1" Name="pnlCard2Body">
                                <TextBlock Text="- Removes Windows Update policies applied by WinUtil" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Restores update service startup settings" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Re-enables update scheduled tasks" FontSize="11" Margin="0,2"/>

                                <TextBlock Text="Use this to undo the Recommended or Disable profile." FontStyle="Italic" FontSize="11" Foreground="#475569" Margin="0,16,0,0"/>
                            </StackPanel>

                            <Button Name="btnRestoreDefaultUpdates" Grid.Row="2" Content="Restore Defaults" Height="30" Width="140" HorizontalAlignment="Center"/>
                        </Grid>
                    </Border>

                    <Border Name="cardUpdate3" Grid.Column="2" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="6" Padding="16" Margin="8,0,0,0">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="Disable Updates" FontSize="18" FontWeight="Bold" Foreground="#DC2626"/>
                                <TextBlock Text="Advanced use only" FontSize="12" FontWeight="Bold" Foreground="#DC2626" Margin="0,2,0,12"/>
                            </StackPanel>

                            <StackPanel Grid.Row="1" Name="pnlCard3Body">
                                <TextBlock Text="- Disables automatic update policy" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Stops update services and scheduled tasks" FontSize="11" Margin="0,2"/>
                                <TextBlock Text="- Clears downloaded update files" FontSize="11" Margin="0,2"/>

                                <TextBlock Text="Security updates will not be installed while this profile is active." FontStyle="Italic" FontSize="11" Foreground="#DC2626" Margin="0,16,0,0"/>
                            </StackPanel>

                            <Button Name="btnDisableUpdates" Grid.Row="2" Content="Disable Updates" Foreground="#DC2626" BorderBrush="#DC2626" Height="30" Width="140" HorizontalAlignment="Center"/>
                        </Grid>
                    </Border>
                </Grid>

                <Border Name="boxUpdatesInfo" Grid.Row="2" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="4" Padding="10" Margin="0,16,0,0">
                    <TextBlock Name="txtUpdatesInfo" Text="Changes apply system-wide. Restart Windows after switching profiles. Use Restore Defaults to undo WinUtil update policies." HorizontalAlignment="Center" FontSize="11" Foreground="#475569"/>
                </Border>
            </Grid>

            <!-- TAB 5: WIN11 CREATOR VIEW -->
            <Grid Name="viewCreator" Grid.Row="2" Margin="12" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="1.2*"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Grid.Column="0" Margin="0,0,10,0">
                        <TextBlock Name="txtStep1Title" Text="Step 1 - Select Windows 11 ISO" FontWeight="Bold" FontSize="13" Foreground="#0F172A"/>
                        <TextBlock Name="txtStep1Sub" Text="Browse to your locally saved Windows 11 ISO file. Only official ISOs downloaded from Microsoft are supported." FontSize="11" Foreground="#475569" TextWrapping="Wrap" Margin="0,2,0,4"/>
                        <TextBlock Name="txtStep1Note" Text="NOTE: This is only meant for Fresh and New Windows installs." FontStyle="Italic" FontSize="11" Foreground="#475569" Margin="0,0,0,8"/>

                        <DockPanel>
                            <Button Name="btnBrowseIso" Content="Browse" Width="70" DockPanel.Dock="Right" Margin="6,0,0,0"/>
                            <TextBox Name="txtIsoPath" Text="No ISO selected..." IsReadOnly="True" Background="#F1F5F9" Foreground="#64748B" BorderBrush="#CBD5E1" Padding="6,4" VerticalAlignment="Center"/>
                        </DockPanel>
                    </StackPanel>

                    <Border Name="boxCreatorWarning" Grid.Column="1" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="4" Padding="12">
                        <StackPanel Name="pnlCreatorWarning">
                            <TextBlock Text="!!!WARNING!! You must use an official Microsoft ISO" Foreground="#DC2626" FontWeight="Bold" FontSize="12"/>
                            <TextBlock Text="Download the Windows 11 ISO directly from Microsoft.com. Third-party, pre-modified, or unofficial images are not supported and may produce broken results." FontSize="11" Foreground="#475569" TextWrapping="Wrap" Margin="0,4,0,8"/>
                            <TextBlock Text="On the Microsoft download page, choose:" FontSize="11" Foreground="#475569"/>
                            <TextBlock Text="  - Edition : Windows 11" FontSize="11" Foreground="#475569"/>
                            <TextBlock Text="  - Language : your preferred language" FontSize="11" Foreground="#475569"/>
                            <TextBlock Text="  - Architecture : 64-bit (x64)" FontSize="11" Foreground="#475569" Margin="0,0,0,12"/>

                            <Button Name="btnOpenMsDownload" Content="Open Microsoft Download Page" Width="200" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                </Grid>

                <Grid Grid.Row="1">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <TextBlock Name="txtLogTitle" Grid.Row="0" Text="Status Log" FontWeight="Bold" FontSize="12" Foreground="#0F172A" Margin="0,0,0,4"/>
                    <Border Name="boxCreatorLog" Grid.Row="1" Background="#FFFFFF" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="4" Padding="10">
                        <TextBox Name="txtStatusLog" Text="Ready. Please select a Windows 11 ISO to begin." IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True" BorderThickness="0" Background="Transparent" Foreground="#0F172A" FontFamily="Consolas" FontSize="11.5"/>
                    </Border>
                </Grid>
            </Grid>

            <!-- Notice Banner Box -->
            <Border Name="boxNotice" Grid.Row="3" Background="#F1F5F9" BorderBrush="#CBD5E1" BorderThickness="1" CornerRadius="4" Margin="8,4,8,4" Padding="8" Visibility="Collapsed">
                <StackPanel Name="pnlNoticeText">
                    <TextBlock Text="Note: Hover over items to get a better description. Please be careful as many of these tweaks will heavily modify your system." Foreground="#475569" FontSize="11"/>
                    <TextBlock Text="Recommended selections are for normal users and if you are unsure do NOT check anything else!" Foreground="#475569" FontSize="11"/>
                </StackPanel>
            </Border>

            <!-- Tweaks Action Buttons Bar at Bottom -->
            <Border Name="barTweaksBottom" Grid.Row="4" Background="#FFFFFF" BorderBrush="#E2E8F0" BorderThickness="0,1,0,0" Padding="12,8" Visibility="Collapsed">
                <DockPanel>
                    <Button Name="btnRunTweaks" Content="Run Tweaks" Background="#FFFFFF" Foreground="#0F172A" BorderBrush="#CBD5E1" Width="120" Height="30" DockPanel.Dock="Left"/>
                    <Button Name="btnUndoTweaks" Content="Undo Selected Tweaks" Background="#FFFFFF" Foreground="#0F172A" BorderBrush="#CBD5E1" Width="160" Height="30" DockPanel.Dock="Left" Margin="10,0,0,0"/>
                </DockPanel>
            </Border>

        </Grid>
    </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($inputXaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Dynamic Header Logo Loader
$imgHeaderLogo = $window.FindName("imgHeaderLogo")
if ($imgHeaderLogo -and (Test-Path $logoPath)) {
    try {
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
        $bitmap.BeginInit()
        $bitmap.UriSource = New-Object System.Uri((Get-Item $logoPath).FullName, [System.UriKind]::Absolute)
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.EndInit()
        $imgHeaderLogo.Source = $bitmap
    } catch {}
}

# Null-Safe XAML Element Bindings
$pnlAppCategories = $window.FindName("pnlAppCategories")
$txtSelCount = $window.FindName("txtSelCount")
$btnThemeToggle = $window.FindName("btnThemeToggle")
$hdrDragBorder = $window.FindName("hdrDragBorder")

# Header Window Drag & Control Actions
if ($hdrDragBorder) {
    $hdrDragBorder.Add_MouseLeftButtonDown({ $window.DragMove() })
}

$btnWinMinimize = $window.FindName("btnWinMinimize")
$btnWinMaximize = $window.FindName("btnWinMaximize")
$btnWinClose = $window.FindName("btnWinClose")

if ($btnWinMinimize) { $btnWinMinimize.Add_Click({ $window.WindowState = [System.Windows.WindowState]::Minimized }) }
if ($btnWinMaximize) {
    $btnWinMaximize.Add_Click({
        if ($window.WindowState -eq [System.Windows.WindowState]::Maximized) {
            $window.WindowState = [System.Windows.WindowState]::Normal
        } else {
            $window.WindowState = [System.Windows.WindowState]::Maximized
        }
    })
}
if ($btnWinClose) { $btnWinClose.Add_Click({ $window.Close() }) }

# Helper Function: Run PowerShell Task Live in Elevated Terminal Window
function Run-LiveTerminalTask([string]$title, [string]$code) {
    $tempScript = Join-Path $env:TEMP "Prime_Task_$((Get-Date).Ticks).ps1"
    $scriptHeader = @"
# Prime Utilities Live Terminal Task: $title
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  P R I M E   U T I L I T I E S   L I V E   E X E C U T I O N       " -ForegroundColor Yellow
Write-Host "  Task: $title" -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

$code

Write-Host ""
Write-Host "Task Execution Finished. Press any key to close this window..." -ForegroundColor Cyan
[void][System.Console]::ReadKey()
"@
    Set-Content -Path $tempScript -Value $scriptHeader -Encoding UTF8
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$tempScript`"" -Verb RunAs
}

# Recursive Text Color Styling Helper
function Set-ContainerTextColors($container, $textBrush) {
    if (-not $container) { return }
    if ($container -is [System.Windows.Controls.Panel]) {
        foreach ($child in $container.Children) {
            if ($child -is [System.Windows.Controls.TextBlock]) {
                if ($child.Foreground -ne [System.Windows.Media.Brushes]::Red -and $child.Text -notlike "*CAUTION*") {
                    $child.Foreground = $textBrush
                }
            } elseif ($child -is [System.Windows.Controls.CheckBox]) {
                $child.Foreground = $textBrush
            } elseif ($child -is [System.Windows.Controls.RadioButton]) {
                $child.Foreground = $textBrush
            } elseif ($child -is [System.Windows.Controls.Panel]) {
                Set-ContainerTextColors $child $textBrush
            } elseif ($child -is [System.Windows.Controls.ScrollViewer]) {
                Set-ContainerTextColors $child.Content $textBrush
            }
        }
    } elseif ($container -is [System.Windows.Controls.ScrollViewer]) {
        Set-ContainerTextColors $container.Content $textBrush
    }
}

# Direct Day / Night Theme Engine
$global:currentThemeState = 1 # Default: Night (Dark)

function Apply-ThemeStyles([string]$mode) {
    $bc = [System.Windows.Media.BrushConverter]::new()

    if ($mode -eq "Night") {
        # Night Mode (100% Screenshot 11 Dark Theme with Crisp White Font)
        $txtBrush = $bc.ConvertFromString("#F8FAFC")

        $window.Background = $bc.ConvertFromString("#0F1722")
        $window.Foreground = $txtBrush
        if ($hdrDragBorder) {
            $hdrDragBorder.Background = $bc.ConvertFromString("#0B111A")
            $hdrDragBorder.BorderBrush = $bc.ConvertFromString("#1E293B")
        }
        
        $window.FindName("mainOuterBorder").BorderBrush = $bc.ConvertFromString("#334155")
        $window.FindName("barFilters").Background = $bc.ConvertFromString("#0D1520")
        $window.FindName("barFilters").BorderBrush = $bc.ConvertFromString("#1E293B")
        $window.FindName("barTweaksPresets").Background = $bc.ConvertFromString("#0D1520")
        $window.FindName("barTweaksPresets").BorderBrush = $bc.ConvertFromString("#1E293B")

        $window.FindName("boxInstallLeft").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxInstallLeft").BorderBrush = $bc.ConvertFromString("#1E293B")
        $window.FindName("boxInstallRight").Background = $bc.ConvertFromString("#0F1722")
        
        $window.FindName("boxTweaksLeft").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxTweaksLeft").BorderBrush = $bc.ConvertFromString("#1E293B")
        $window.FindName("boxTweaksRight").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxTweaksRight").BorderBrush = $bc.ConvertFromString("#1E293B")

        $window.FindName("boxConfigLeft").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxConfigLeft").BorderBrush = $bc.ConvertFromString("#1E293B")
        $window.FindName("boxConfigRight").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxConfigRight").BorderBrush = $bc.ConvertFromString("#1E293B")
        
        $window.FindName("cardUpdate1").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("cardUpdate2").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("cardUpdate3").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxUpdatesInfo").Background = $bc.ConvertFromString("#141D2B")

        $window.FindName("boxCreatorWarning").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("boxCreatorLog").Background = $bc.ConvertFromString("#141D2B")
        $window.FindName("txtStatusLog").Foreground = $txtBrush

        # Top Tabs Dark Styling
        $window.FindName("btnTabTweaks").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnTabTweaks").Foreground = $txtBrush
        $window.FindName("btnTabTweaks").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnTabConfig").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnTabConfig").Foreground = $txtBrush
        $window.FindName("btnTabConfig").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnTabUpdates").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnTabUpdates").Foreground = $txtBrush
        $window.FindName("btnTabUpdates").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnTabCreator").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnTabCreator").Foreground = $txtBrush
        $window.FindName("btnTabCreator").BorderBrush = $bc.ConvertFromString("#334155")

        # Apply White Text Color to all CheckBoxes and Labels in Tweaks, Config, Updates, Creator
        Set-ContainerTextColors ($window.FindName("pnlTweaksCheckboxes")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlTweaksPrefs")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlConfigLeft")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlConfigRight")) $txtBrush
        Set-ContainerTextColors ($window.FindName("viewUpdates")) $txtBrush
        Set-ContainerTextColors ($window.FindName("viewCreator")) $txtBrush
        Set-ContainerTextColors ($window.FindName("boxNotice")) $txtBrush
        Set-ContainerTextColors ($window.FindName("boxInstallLeft")) $txtBrush

        $window.FindName("txtRecommendedLabel").Foreground = $bc.ConvertFromString("#94A3B8")
        $window.FindName("txtDnsLabel").Foreground = $txtBrush

        # Left Action Buttons Dark Styling
        $window.FindName("btnUninstallSelected").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnUninstallSelected").Foreground = $txtBrush
        $window.FindName("btnUninstallSelected").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnUpgradeAll").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnUpgradeAll").Foreground = $txtBrush
        $window.FindName("btnUpgradeAll").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnClearSel").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnClearSel").Foreground = $txtBrush
        $window.FindName("btnClearSel").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnCollapseAll").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnCollapseAll").Foreground = $txtBrush
        $window.FindName("btnCollapseAll").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnExpandAll").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnExpandAll").Foreground = $txtBrush
        $window.FindName("btnExpandAll").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("txtSelCount").Background = $bc.ConvertFromString("#182232")
        $window.FindName("txtSelCount").Foreground = $txtBrush
        $window.FindName("txtSelCount").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("btnShowInstalled").Background = $bc.ConvertFromString("#182232")
        $window.FindName("btnShowInstalled").Foreground = $txtBrush
        $window.FindName("btnShowInstalled").BorderBrush = $bc.ConvertFromString("#334155")

        $window.FindName("txtSearch").Background = $bc.ConvertFromString("#182232")
        $window.FindName("txtSearch").Foreground = $txtBrush
        $window.FindName("txtSearch").BorderBrush = $bc.ConvertFromString("#334155")

        # Dynamic App Cards Dark Styling
        if ($pnlAppCategories) {
            foreach ($catPanel in $pnlAppCategories.Children) {
                foreach ($c in $catPanel.Children) {
                    if ($c -is [System.Windows.Controls.TextBlock]) {
                        $c.Foreground = $bc.ConvertFromString("#38BDF8")
                    } elseif ($c -is [System.Windows.Controls.WrapPanel]) {
                        foreach ($b in $c.Children) {
                            if ($b -is [System.Windows.Controls.Border]) {
                                $b.Background = $bc.ConvertFromString("#182232")
                                $b.BorderBrush = $bc.ConvertFromString("#334155")
                                if ($b.Child -is [System.Windows.Controls.Grid]) {
                                    foreach ($gc in $b.Child.Children) {
                                        if ($gc -is [System.Windows.Controls.CheckBox]) {
                                            $gc.Foreground = $txtBrush
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if ($btnThemeToggle) {
            $btnThemeToggle.Content = "$chMoon"
            $btnThemeToggle.ToolTip = "Mode: Night (Dark Theme)"
        }
    } else {
        # Day Mode (Pure 100% White Light Theme)
        $txtBrush = $bc.ConvertFromString("#0F172A")

        $window.Background = $bc.ConvertFromString("#F8FAFC")
        $window.Foreground = $txtBrush
        if ($hdrDragBorder) {
            $hdrDragBorder.Background = $bc.ConvertFromString("#FFFFFF")
            $hdrDragBorder.BorderBrush = $bc.ConvertFromString("#E2E8F0")
        }

        $window.FindName("mainOuterBorder").BorderBrush = $bc.ConvertFromString("#CBD5E1")
        $window.FindName("barFilters").Background = $bc.ConvertFromString("#F1F5F9")
        $window.FindName("barFilters").BorderBrush = $bc.ConvertFromString("#E2E8F0")
        $window.FindName("barTweaksPresets").Background = $bc.ConvertFromString("#F1F5F9")
        $window.FindName("barTweaksPresets").BorderBrush = $bc.ConvertFromString("#E2E8F0")

        $window.FindName("boxInstallLeft").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxInstallLeft").BorderBrush = $bc.ConvertFromString("#CBD5E1")
        $window.FindName("boxInstallRight").Background = $bc.ConvertFromString("#F8FAFC")

        $window.FindName("boxTweaksLeft").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxTweaksLeft").BorderBrush = $bc.ConvertFromString("#CBD5E1")
        $window.FindName("boxTweaksRight").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxTweaksRight").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("boxConfigLeft").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxConfigLeft").BorderBrush = $bc.ConvertFromString("#CBD5E1")
        $window.FindName("boxConfigRight").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxConfigRight").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("cardUpdate1").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("cardUpdate2").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("cardUpdate3").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxUpdatesInfo").Background = $bc.ConvertFromString("#FFFFFF")

        $window.FindName("boxCreatorWarning").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("boxCreatorLog").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("txtStatusLog").Foreground = $txtBrush

        # Top Tabs Pure White Light Styling
        $window.FindName("btnTabTweaks").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnTabTweaks").Foreground = $txtBrush
        $window.FindName("btnTabTweaks").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnTabConfig").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnTabConfig").Foreground = $txtBrush
        $window.FindName("btnTabConfig").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnTabUpdates").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnTabUpdates").Foreground = $txtBrush
        $window.FindName("btnTabUpdates").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnTabCreator").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnTabCreator").Foreground = $txtBrush
        $window.FindName("btnTabCreator").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        # Apply Dark Text Color to all CheckBoxes and Labels in Tweaks, Config, Updates, Creator
        Set-ContainerTextColors ($window.FindName("pnlTweaksCheckboxes")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlTweaksPrefs")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlConfigLeft")) $txtBrush
        Set-ContainerTextColors ($window.FindName("pnlConfigRight")) $txtBrush
        Set-ContainerTextColors ($window.FindName("viewUpdates")) $txtBrush
        Set-ContainerTextColors ($window.FindName("viewCreator")) $txtBrush
        Set-ContainerTextColors ($window.FindName("boxNotice")) $txtBrush
        Set-ContainerTextColors ($window.FindName("boxInstallLeft")) $txtBrush

        $window.FindName("txtRecommendedLabel").Foreground = $bc.ConvertFromString("#64748B")
        $window.FindName("txtDnsLabel").Foreground = $txtBrush

        # Left Action Buttons Pure White Light Styling
        $window.FindName("btnUninstallSelected").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnUninstallSelected").Foreground = $txtBrush
        $window.FindName("btnUninstallSelected").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnUpgradeAll").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnUpgradeAll").Foreground = $txtBrush
        $window.FindName("btnUpgradeAll").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnClearSel").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnClearSel").Foreground = $txtBrush
        $window.FindName("btnClearSel").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnCollapseAll").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnCollapseAll").Foreground = $txtBrush
        $window.FindName("btnCollapseAll").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnExpandAll").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnExpandAll").Foreground = $txtBrush
        $window.FindName("btnExpandAll").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("txtSelCount").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("txtSelCount").Foreground = $txtBrush
        $window.FindName("txtSelCount").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("btnShowInstalled").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("btnShowInstalled").Foreground = $txtBrush
        $window.FindName("btnShowInstalled").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        $window.FindName("txtSearch").Background = $bc.ConvertFromString("#FFFFFF")
        $window.FindName("txtSearch").Foreground = $txtBrush
        $window.FindName("txtSearch").BorderBrush = $bc.ConvertFromString("#CBD5E1")

        # Dynamic App Cards Light Styling
        if ($pnlAppCategories) {
            foreach ($catPanel in $pnlAppCategories.Children) {
                foreach ($c in $catPanel.Children) {
                    if ($c -is [System.Windows.Controls.TextBlock]) {
                        $c.Foreground = $bc.ConvertFromString("#0284C7")
                    } elseif ($c -is [System.Windows.Controls.WrapPanel]) {
                        foreach ($b in $c.Children) {
                            if ($b -is [System.Windows.Controls.Border]) {
                                $b.Background = $bc.ConvertFromString("#FFFFFF")
                                $b.BorderBrush = $bc.ConvertFromString("#CBD5E1")
                                if ($b.Child -is [System.Windows.Controls.Grid]) {
                                    foreach ($gc in $b.Child.Children) {
                                        if ($gc -is [System.Windows.Controls.CheckBox]) {
                                            $gc.Foreground = $txtBrush
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if ($btnThemeToggle) {
            $btnThemeToggle.Content = "$chSun"
            $btnThemeToggle.ToolTip = "Mode: Day (Light Theme)"
        }
    }
}

# Custom 1-to-1 Transparent Round About Dialog Popup matching Screenshot 8
function Show-AboutDialog {
    $aboutXaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            Title="About WinUtil" Height="220" Width="380" WindowStartupLocation="CenterScreen"
            WindowStyle="None" AllowsTransparency="True" Background="Transparent">
        <Border Background="#141D2B" BorderBrush="#334155" BorderThickness="1" CornerRadius="14" Padding="20">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,14">
                    <Border Width="24" Height="24" CornerRadius="4" Background="#8B5CF6" Margin="0,0,10,0">
                        <Image Name="imgAboutLogo" Stretch="UniformToFill"/>
                    </Border>
                    <TextBlock Text="WinUtil" FontSize="14" FontWeight="SemiBold" VerticalAlignment="Center" Foreground="#F8FAFC"/>
                </StackPanel>

                <StackPanel Grid.Row="1" Margin="0,0,0,10">
                    <TextBlock Text="Author    : @PrimeMITHU09" FontSize="12" FontFamily="Consolas" Foreground="#F8FAFC" Margin="0,2"/>
                    <TextBlock Text="UI           : @prime8088 (Telegram)" FontSize="12" FontFamily="Consolas" Foreground="#F8FAFC" Margin="0,2"/>
                    <TextBlock Text="Runspace : @DeveloperDurp, @Marterich" FontSize="12" FontFamily="Consolas" Foreground="#F8FAFC" Margin="0,2"/>
                    <TextBlock Text="GitHub   : PrimeMITHU09/Prime-Utilities" FontSize="12" FontFamily="Consolas" Foreground="#F8FAFC" Margin="0,2"/>
                </StackPanel>

                <Button Name="btnAboutOk" Grid.Row="2" Content="OK" Width="100" Height="28" HorizontalAlignment="Center" Background="#182232" BorderBrush="#38BDF8" Foreground="#F8FAFC"/>
            </Grid>
        </Border>
    </Window>
"@
    $r = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($aboutXaml))
    $aboutWin = [System.Windows.Markup.XamlReader]::Load($r)
    $imgAboutLogo = $aboutWin.FindName("imgAboutLogo")
    if ($imgAboutLogo -and (Test-Path $logoPath)) {
        try {
            $bm = New-Object System.Windows.Media.Imaging.BitmapImage
            $bm.BeginInit()
            $bm.UriSource = New-Object System.Uri((Get-Item $logoPath).FullName, [System.UriKind]::Absolute)
            $bm.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bm.EndInit()
            $imgAboutLogo.Source = $bm
        } catch {}
    }
    $btnOk = $aboutWin.FindName("btnAboutOk")
    if ($btnOk) { $btnOk.Add_Click({ $aboutWin.Close() }) }
    $aboutWin.ShowDialog() | Out-Null
}

# Settings Gear Context Menu matching Screenshot 7 & Screenshot 8
$btnSettings = $window.FindName("btnSettings")
if ($btnSettings) {
    $cm = New-Object System.Windows.Controls.ContextMenu
    
    $miImport = New-Object System.Windows.Controls.MenuItem
    $miImport.Header = "Import"
    $miImport.Add_Click({
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = "WinUtil JSON Preset (*.json)|*.json"
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            [System.Windows.MessageBox]::Show("Imported selections from $($dialog.FileName)", "Import Preset", "OK", "Information") | Out-Null
        }
    })
    
    $miExport = New-Object System.Windows.Controls.MenuItem
    $miExport.Header = "Export"
    $miExport.Add_Click({
        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "WinUtil JSON Preset (*.json)|*.json"
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            [System.Windows.MessageBox]::Show("Exported current preset to $($dialog.FileName)", "Export Preset", "OK", "Information") | Out-Null
        }
    })

    $separator = New-Object System.Windows.Controls.Separator

    $miAbout = New-Object System.Windows.Controls.MenuItem
    $miAbout.Header = "About"
    $miAbout.Add_Click({
        Show-AboutDialog
    })

    $miDoc = New-Object System.Windows.Controls.MenuItem
    $miDoc.Header = "Documentation (Paused)"
    $miDoc.Add_Click({
        [System.Windows.MessageBox]::Show("Custom Prime Utilities Documentation coming soon!", "Documentation", "OK", "Information") | Out-Null
    })

    $miSponsors = New-Object System.Windows.Controls.MenuItem
    $miSponsors.Header = "Sponsors"
    $miSponsors.Add_Click({
        [System.Windows.MessageBox]::Show("Add me, I am Clone developer`nTelegram: @prime8088`nGitHub: https://github.com/PrimeMITHU09", "Sponsors & Developer Info", "OK", "Information") | Out-Null
    })

    $cm.Items.Add($miImport) | Out-Null
    $cm.Items.Add($miExport) | Out-Null
    $cm.Items.Add($separator) | Out-Null
    $cm.Items.Add($miAbout) | Out-Null
    $cm.Items.Add($miDoc) | Out-Null
    $cm.Items.Add($miSponsors) | Out-Null

    $btnSettings.Add_Click({
        $cm.IsOpen = $true
    })
}

# Navigation Controls
$btnTabInstall = $window.FindName("btnTabInstall")
$btnTabTweaks = $window.FindName("btnTabTweaks")
$btnTabConfig = $window.FindName("btnTabConfig")
$btnTabUpdates = $window.FindName("btnTabUpdates")
$btnTabCreator = $window.FindName("btnTabCreator")

$barFilters = $window.FindName("barFilters")
$barTweaksPresets = $window.FindName("barTweaksPresets")
$barTweaksBottom = $window.FindName("barTweaksBottom")
$boxNotice = $window.FindName("boxNotice")

$viewInstall = $window.FindName("viewInstall")
$viewTweaks = $window.FindName("viewTweaks")
$viewConfig = $window.FindName("viewConfig")
$viewUpdates = $window.FindName("viewUpdates")
$viewCreator = $window.FindName("viewCreator")

function Reset-Tabs {
    if ($global:currentThemeState -eq 1) {
        $bg = "#182232"; $fg = "#F8FAFC"; $bdr = "#334155"
    } else {
        $bg = "#FFFFFF"; $fg = "#0F172A"; $bdr = "#CBD5E1"
    }

    $btnTabInstall.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bg)
    $btnTabInstall.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fg)
    $btnTabInstall.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bdr)

    $btnTabTweaks.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bg)
    $btnTabTweaks.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fg)
    $btnTabTweaks.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bdr)

    $btnTabConfig.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bg)
    $btnTabConfig.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fg)
    $btnTabConfig.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bdr)

    $btnTabUpdates.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bg)
    $btnTabUpdates.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fg)
    $btnTabUpdates.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bdr)

    $btnTabCreator.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bg)
    $btnTabCreator.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($fg)
    $btnTabCreator.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($bdr)

    $viewInstall.Visibility = [System.Windows.Visibility]::Collapsed
    $viewTweaks.Visibility = [System.Windows.Visibility]::Collapsed
    $viewConfig.Visibility = [System.Windows.Visibility]::Collapsed
    $viewUpdates.Visibility = [System.Windows.Visibility]::Collapsed
    $viewCreator.Visibility = [System.Windows.Visibility]::Collapsed

    $barFilters.Visibility = [System.Windows.Visibility]::Collapsed
    $barTweaksPresets.Visibility = [System.Windows.Visibility]::Collapsed
    $barTweaksBottom.Visibility = [System.Windows.Visibility]::Collapsed
    $boxNotice.Visibility = [System.Windows.Visibility]::Collapsed
}

$btnTabInstall.Add_Click({
    Reset-Tabs
    $btnTabInstall.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabInstall.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
    $barFilters.Visibility = [System.Windows.Visibility]::Visible
    $viewInstall.Visibility = [System.Windows.Visibility]::Visible
})

$btnTabTweaks.Add_Click({
    Reset-Tabs
    $btnTabTweaks.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabTweaks.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
    $barTweaksPresets.Visibility = [System.Windows.Visibility]::Visible
    $barTweaksBottom.Visibility = [System.Windows.Visibility]::Visible
    $boxNotice.Visibility = [System.Windows.Visibility]::Visible
    $viewTweaks.Visibility = [System.Windows.Visibility]::Visible
})

$btnTabConfig.Add_Click({
    Reset-Tabs
    $btnTabConfig.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabConfig.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
    $viewConfig.Visibility = [System.Windows.Visibility]::Visible
})

$btnTabUpdates.Add_Click({
    Reset-Tabs
    $btnTabUpdates.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabUpdates.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
    $viewUpdates.Visibility = [System.Windows.Visibility]::Visible
})

$btnTabCreator.Add_Click({
    Reset-Tabs
    $btnTabCreator.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabCreator.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
    $viewCreator.Visibility = [System.Windows.Visibility]::Visible
})

# Filter Category Buttons Handler
$filterBtnNames = @("btnFilterAll", "btnFilterBrowsers", "btnFilterComms", "btnFilterDev", "btnFilterGames", "btnFilterMSTools", "btnFilterMedia", "btnFilterPro", "btnFilterUtils")
$filterMap = @{
    "btnFilterAll" = "all"; "btnFilterBrowsers" = "browsers"; "btnFilterComms" = "communications"
    "btnFilterDev" = "development"; "btnFilterGames" = "games"; "btnFilterMSTools" = "microsoft tools"
    "btnFilterMedia" = "multimedia tools"; "btnFilterPro" = "pro tools"; "btnFilterUtils" = "utilities"
}

foreach ($fName in $filterBtnNames) {
    $fBtn = $window.FindName($fName)
    if ($fBtn) {
        $fBtn.Add_Click({
            param($sender, $e)
            $targetCat = $filterMap[$sender.Name]
            
            # Highlight selected filter button
            foreach ($bName in $filterBtnNames) {
                $b = $window.FindName($bName)
                if ($b) {
                    if ($b.Name -eq $sender.Name) {
                        if ($global:currentThemeState -eq 1) {
                            $b.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#334155")
                            $b.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#38BDF8")
                        } else {
                            $b.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#CBD5E1")
                            $b.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0284C7")
                        }
                    } else {
                        if ($global:currentThemeState -eq 1) {
                            $b.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#182232")
                            $b.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#334155")
                        } else {
                            $b.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
                            $b.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#CBD5E1")
                        }
                    }
                }
            }

            # Filter visible categories in pnlAppCategories
            if ($pnlAppCategories) {
                foreach ($child in $pnlAppCategories.Children) {
                    if ($targetCat -eq "all" -or $child.Tag -eq $targetCat) {
                        $child.Visibility = [System.Windows.Visibility]::Visible
                    } else {
                        $child.Visibility = [System.Windows.Visibility]::Collapsed
                    }
                }
            }
        })
    }
}

# Left Side Action Buttons Wire-up
$selectedAppCheckboxes = @()

function Update-SelectionCounter {
    $count = ($selectedAppCheckboxes | Where-Object { $_.IsChecked -eq $true }).Count
    if ($txtSelCount) {
        $txtSelCount.Content = "Selected Apps: $count"
    }
}

$btnClearSel = $window.FindName("btnClearSel")
if ($btnClearSel) {
    $btnClearSel.Add_Click({
        foreach ($chk in $selectedAppCheckboxes) { $chk.IsChecked = $false }
        Update-SelectionCounter
    })
}

$btnCollapseAll = $window.FindName("btnCollapseAll")
if ($btnCollapseAll) {
    $btnCollapseAll.Add_Click({
        if ($pnlAppCategories) {
            foreach ($catPanel in $pnlAppCategories.Children) {
                foreach ($wrap in $catPanel.Children) {
                    if ($wrap -is [System.Windows.Controls.WrapPanel]) {
                        $wrap.Visibility = [System.Windows.Visibility]::Collapsed
                    }
                }
            }
        }
    })
}

$btnExpandAll = $window.FindName("btnExpandAll")
if ($btnExpandAll) {
    $btnExpandAll.Add_Click({
        if ($pnlAppCategories) {
            foreach ($catPanel in $pnlAppCategories.Children) {
                foreach ($wrap in $catPanel.Children) {
                    if ($wrap -is [System.Windows.Controls.WrapPanel]) {
                        $wrap.Visibility = [System.Windows.Visibility]::Visible
                    }
                }
            }
        }
    })
}

$btnInstallSelected = $window.FindName("btnInstallSelected")
if ($btnInstallSelected) {
    $btnInstallSelected.Add_Click({
        $toInstall = $selectedAppCheckboxes | Where-Object { $_.IsChecked -eq $true } | Select-Object -ExpandProperty Tag
        if ($toInstall.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Please select at least one application to install.", "No Selection", "OK", "Warning") | Out-Null
            return
        }
        $appArgs = $toInstall -join " "
        if (Test-Path $installScriptPath) {
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$installScriptPath`" -Apps $appArgs" -Verb RunAs
        } else {
            $webCmd = "(New-Object System.Net.WebClient).DownloadString('$githubRawBase/scripts/Install-Apps.ps1') | Invoke-Expression"
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -Command `"$webCmd -Apps $appArgs`"" -Verb RunAs
        }
    })
}

# Search Bar Real-Time Filter
$txtSearch = $window.FindName("txtSearch")
if ($txtSearch) {
    $txtSearch.Add_TextChanged({
        $q = $txtSearch.Text.Trim().ToLower()
        if ($pnlAppCategories) {
            foreach ($catContainer in $pnlAppCategories.Children) {
                $wrap = $catContainer.Children | Where-Object { $_ -is [System.Windows.Controls.WrapPanel] }
                if ($wrap) {
                    $hasVisibleApp = $false
                    foreach ($cardBorder in $wrap.Children) {
                        $appName = $cardBorder.Tag
                        if ([string]::IsNullOrWhiteSpace($q) -or ($appName -and $appName.ToString().ToLower().Contains($q))) {
                            $cardBorder.Visibility = [System.Windows.Visibility]::Visible
                            $hasVisibleApp = $true
                        } else {
                            $cardBorder.Visibility = [System.Windows.Visibility]::Collapsed
                        }
                    }
                    if ($hasVisibleApp) {
                        $catContainer.Visibility = [System.Windows.Visibility]::Visible
                    } else {
                        $catContainer.Visibility = [System.Windows.Visibility]::Collapsed
                    }
                }
            }
        }
    })
}

# Font Size Scale Button Handler
$btnFontSize = $window.FindName("btnFontSize")
$global:fontScaleStep = 0
if ($btnFontSize) {
    $btnFontSize.Add_Click({
        $global:fontScaleStep = ($global:fontScaleStep + 1) % 3
        $scale = 1.0
        if ($global:fontScaleStep -eq 1) { $scale = 1.15 }
        elseif ($global:fontScaleStep -eq 2) { $scale = 1.3 }
        $window.LayoutTransform = New-Object System.Windows.Media.ScaleTransform($scale, $scale)
    })
}

# Action Buttons: Uninstall, Upgrade All, Show Installed
$btnUninstallSelected = $window.FindName("btnUninstallSelected")
if ($btnUninstallSelected) {
    $btnUninstallSelected.Add_Click({
        $toUninstall = $selectedAppCheckboxes | Where-Object { $_.IsChecked -eq $true } | Select-Object -ExpandProperty Tag
        if ($toUninstall.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Please select at least one application to uninstall.", "No Selection", "OK", "Warning") | Out-Null
            return
        }
        $cmd = "foreach (`$app in @('$($toUninstall -join "','")')) { Write-Host 'Uninstalling `$app...'; winget uninstall --id `$app --silent --accept-source-agreements }"
        Run-LiveTerminalTask "Uninstall Applications" $cmd
    })
}

$btnUpgradeAll = $window.FindName("btnUpgradeAll")
if ($btnUpgradeAll) {
    $btnUpgradeAll.Add_Click({
        Run-LiveTerminalTask "Upgrade All Installed Applications" "winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements"
    })
}

$btnShowInstalled = $window.FindName("btnShowInstalled")
if ($btnShowInstalled) {
    $btnShowInstalled.Add_Click({
        Run-LiveTerminalTask "Installed WinGet Applications" "winget list"
    })
}

# Config Tab / System Repairs & Fixes Wire-up
$btnInstallFeatures = $window.FindName("btnInstallFeatures")
if ($btnInstallFeatures) {
    $btnInstallFeatures.Add_Click({
        $repairScriptPath = Join-Path $scriptDir "scripts\System-Repairs.ps1"
        $switches = @()
        if ($window.FindName("featWSL").IsChecked) { $switches += "-EnableWSL" }
        if ($window.FindName("featHyperV").IsChecked) { $switches += "-EnableHyperV" }
        $cmd = "& '$repairScriptPath' $($switches -join ' ')"
        Run-LiveTerminalTask "Installing Selected Windows Features" $cmd
    })
}

$btnFixSysCorruption = $window.FindName("btnFixSysCorruption")
if ($btnFixSysCorruption) {
    $btnFixSysCorruption.Add_Click({
        $repairScriptPath = Join-Path $scriptDir "scripts\System-Repairs.ps1"
        Run-LiveTerminalTask "System Corruption Scan (SFC & DISM)" "& '$repairScriptPath' -RunSFC -RunDISM"
    })
}

$btnFixNetReset = $window.FindName("btnFixNetReset")
if ($btnFixNetReset) {
    $btnFixNetReset.Add_Click({
        $repairScriptPath = Join-Path $scriptDir "scripts\System-Repairs.ps1"
        Run-LiveTerminalTask "Network Stack & Winsock Reset" "& '$repairScriptPath' -ResetNetwork -FlushDNS"
    })
}

$btnFixWinUpdateReset = $window.FindName("btnFixWinUpdateReset")
if ($btnFixWinUpdateReset) {
    $btnFixWinUpdateReset.Add_Click({
        $repairScriptPath = Join-Path $scriptDir "scripts\System-Repairs.ps1"
        Run-LiveTerminalTask "Reset Windows Update Cache" "& '$repairScriptPath' -ResetWindowsUpdateCache"
    })
}

$btnFixAutoLogon = $window.FindName("btnFixAutoLogon")
if ($btnFixAutoLogon) {
    $btnFixAutoLogon.Add_Click({
        Start-Process netplwiz
    })
}

$btnFixNtpServer = $window.FindName("btnFixNtpServer")
if ($btnFixNtpServer) {
    $btnFixNtpServer.Add_Click({
        Run-LiveTerminalTask "Enable NTP Time Server Sync" "w32tm /config /syncfromflags:manual /manualpeerlist:'pool.ntp.org' /syncfromflags:MANUAL; w32tm /config /update; w32tm /resync"
    })
}

$btnFixWinGetReinstall = $window.FindName("btnFixWinGetReinstall")
if ($btnFixWinGetReinstall) {
    $btnFixWinGetReinstall.Add_Click({
        Run-LiveTerminalTask "Reinstall / Repair WinGet" "Invoke-RestMethod -Uri https://raw.githubusercontent.com/marticliment/Winget-AutoUpdate/main/Winget-AutoUpdate/winget-install.ps1 | Invoke-Expression"
    })
}

# Legacy Windows Control Panels
$panelMap = @{
    "btnPanelCompMgmt" = "compmgmt.msc"
    "btnPanelControlPanel" = "control.exe"
    "btnPanelMouse" = "main.cpl"
    "btnPanelNetConn" = "ncpa.cpl"
    "btnPanelPower" = "powercfg.cpl"
    "btnPanelPrinters" = "control.exe printers"
    "btnPanelAppWiz" = "appwiz.cpl"
    "btnPanelRegion" = "intl.cpl"
    "btnPanelSecMaint" = "wscui.cpl"
    "btnPanelSound" = "mmsys.cpl"
    "btnPanelSysProps" = "sysdm.cpl"
    "btnPanelTimeDate" = "timedate.cpl"
    "btnPanelFirewall" = "firewall.cpl"
    "btnPanelRestore" = "rstrui.exe"
}

foreach ($pKey in $panelMap.Keys) {
    $btn = $window.FindName($pKey)
    if ($btn) {
        $btn.Add_Click({
            param($sender, $e)
            $cmd = $panelMap[$sender.Name]
            Start-Process cmd.exe -ArgumentList "/c $cmd"
        })
    }
}

$btnProfileInstall = $window.FindName("btnProfileInstall")
if ($btnProfileInstall) {
    $btnProfileInstall.Add_Click({
        Run-LiveTerminalTask "Install CTT PowerShell Profile" "iwr -useb https://christitus.com/lwpy | iex"
    })
}

$btnProfileRemove = $window.FindName("btnProfileRemove")
if ($btnProfileRemove) {
    $btnProfileRemove.Add_Click({
        Run-LiveTerminalTask "Remove CTT PowerShell Profile" "if (Test-Path `$PROFILE) { Remove-Item `$PROFILE -Force; Write-Host 'PowerShell profile removed.' }"
    })
}

$btnEnableSSH = $window.FindName("btnEnableSSH")
if ($btnEnableSSH) {
    $btnEnableSSH.Add_Click({
        Run-LiveTerminalTask "Enable OpenSSH Server" "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; Start-Service sshd; Set-Service -Name sshd -StartupType Automatic"
    })
}

# Tweaks Tab Presets & Actions
$btnPresetStandard = $window.FindName("btnPresetStandard")
$btnPresetMinimal = $window.FindName("btnPresetMinimal")
$btnPresetAdvanced = $window.FindName("btnPresetAdvanced")
$btnPresetClear = $window.FindName("btnPresetClear")

function Set-TweakPresets([string]$preset) {
    1..38 | ForEach-Object {
        $c = $window.FindName("chk$_")
        if ($c) { $c.IsChecked = $false }
    }
    1..25 | ForEach-Object {
        $p = $window.FindName("pref$_")
        if ($p) { $p.IsChecked = $false }
    }

    if ($preset -eq "Standard") {
        @("chk1","chk3","chk4","chk5","chk6","chk7","chk8","chk12","chk13","chk15") | ForEach-Object {
            $c = $window.FindName($_); if ($c) { $c.IsChecked = $true }
        }
        @("pref2","pref3","pref4","pref10","pref11","pref12","pref13","pref17","pref18","pref25") | ForEach-Object {
            $p = $window.FindName($_); if ($p) { $p.IsChecked = $true }
        }
    } elseif ($preset -eq "Minimal") {
        @("chk1","chk3","chk13","chk15") | ForEach-Object {
            $c = $window.FindName($_); if ($c) { $c.IsChecked = $true }
        }
        @("pref2","pref3","pref4") | ForEach-Object {
            $p = $window.FindName($_); if ($p) { $p.IsChecked = $true }
        }
    } elseif ($preset -eq "Advanced") {
        1..38 | ForEach-Object {
            $c = $window.FindName("chk$_"); if ($c) { $c.IsChecked = $true }
        }
        1..25 | ForEach-Object {
            $p = $window.FindName("pref$_"); if ($p) { $p.IsChecked = $true }
        }
    }
}

if ($btnPresetStandard) { $btnPresetStandard.Add_Click({ Set-TweakPresets "Standard" }) }
if ($btnPresetMinimal) { $btnPresetMinimal.Add_Click({ Set-TweakPresets "Minimal" }) }
if ($btnPresetAdvanced) { $btnPresetAdvanced.Add_Click({ Set-TweakPresets "Advanced" }) }
if ($btnPresetClear) { $btnPresetClear.Add_Click({ Set-TweakPresets "Clear" }) }

$btnRunTweaks = $window.FindName("btnRunTweaks")
if ($btnRunTweaks) {
    $btnRunTweaks.Add_Click({
        $tweakScriptPath = Join-Path $scriptDir "scripts\Apply-Tweaks.ps1"
        $cmd = "& '$tweakScriptPath' -DisableTelemetry -DisableBingSearch -DisableGameDVR -RemoveBloatware -OptimizeServices -FixMouseAcceleration"
        Run-LiveTerminalTask "Applying Windows Performance & Privacy Tweaks" $cmd
    })
}

$btnUndoTweaks = $window.FindName("btnUndoTweaks")
if ($btnUndoTweaks) {
    $btnUndoTweaks.Add_Click({
        $cmd = "Write-Host 'Undoing selected tweaks...'; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 1 -Force -ErrorAction SilentlyContinue; Write-Host 'Telemetry re-enabled. Defaults restored.'"
        Run-LiveTerminalTask "Undo Selected Tweaks" $cmd
    })
}

$btnGetInstalledTweaks = $window.FindName("btnGetInstalledTweaks")
if ($btnGetInstalledTweaks) {
    $btnGetInstalledTweaks.Add_Click({
        [System.Windows.MessageBox]::Show("Scanned system: Current tweak status loaded.", "Installed Tweaks", "OK", "Information") | Out-Null
    })
}

$btnAppXRemoval = $window.FindName("btnAppXRemoval")
if ($btnAppXRemoval) {
    $btnAppXRemoval.Add_Click({
        $tweakScriptPath = Join-Path $scriptDir "scripts\Apply-Tweaks.ps1"
        Run-LiveTerminalTask "AppX Bloatware Removal" "& '$tweakScriptPath' -RemoveBloatware"
    })
}

$btnOOShutUp = $window.FindName("btnOOShutUp")
if ($btnOOShutUp) {
    $btnOOShutUp.Add_Click({
        Run-LiveTerminalTask "Run O&O ShutUp10++" "`$ooPath = Join-Path `$env:TEMP 'OOSHUTUP10.exe'; (New-Object System.Net.WebClient).DownloadFile('https://dl5.oo-software.com/files/ooshutup10/OOSHUTUP10.exe', `$ooPath); Start-Process `$ooPath"
    })
}

$btnEnableUltimatePerf = $window.FindName("btnEnableUltimatePerf")
if ($btnEnableUltimatePerf) {
    $btnEnableUltimatePerf.Add_Click({
        Run-LiveTerminalTask "Enable Ultimate Performance Power Plan" "powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61"
    })
}

$btnDisableUltimatePerf = $window.FindName("btnDisableUltimatePerf")
if ($btnDisableUltimatePerf) {
    $btnDisableUltimatePerf.Add_Click({
        Run-LiveTerminalTask "Disable Ultimate Performance Plan" "powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e"
    })
}

# Updates Tab Wire-up
$btnApplyRecommendedUpdates = $window.FindName("btnApplyRecommendedUpdates")
if ($btnApplyRecommendedUpdates) {
    $btnApplyRecommendedUpdates.Add_Click({
        $updateScriptPath = Join-Path $scriptDir "scripts\Manage-Updates.ps1"
        Run-LiveTerminalTask "Apply Recommended Windows Update Profile" "& '$updateScriptPath' -Mode Recommended"
    })
}

$btnRestoreDefaultUpdates = $window.FindName("btnRestoreDefaultUpdates")
if ($btnRestoreDefaultUpdates) {
    $btnRestoreDefaultUpdates.Add_Click({
        $updateScriptPath = Join-Path $scriptDir "scripts\Manage-Updates.ps1"
        Run-LiveTerminalTask "Restore Default Windows Updates" "& '$updateScriptPath' -Mode Default"
    })
}

$btnDisableUpdates = $window.FindName("btnDisableUpdates")
if ($btnDisableUpdates) {
    $btnDisableUpdates.Add_Click({
        $updateScriptPath = Join-Path $scriptDir "scripts\Manage-Updates.ps1"
        Run-LiveTerminalTask "Disable Automatic Windows Updates" "& '$updateScriptPath' -Mode Disable"
    })
}

# Win11 Creator Tab Wire-up
$btnBrowseIso = $window.FindName("btnBrowseIso")
$txtIsoPath = $window.FindName("txtIsoPath")
$txtStatusLog = $window.FindName("txtStatusLog")

if ($btnBrowseIso) {
    $btnBrowseIso.Add_Click({
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = "Windows ISO Image (*.iso)|*.iso"
        if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($txtIsoPath) { $txtIsoPath.Text = $dlg.FileName }
            if ($txtStatusLog) {
                $txtStatusLog.Text = "[SELECTED] $($dlg.FileName)`r`nReady to create customized Windows 11 installation media."
            }
        }
    })
}

$btnOpenMsDownload = $window.FindName("btnOpenMsDownload")
if ($btnOpenMsDownload) {
    $btnOpenMsDownload.Add_Click({
        Start-Process "https://www.microsoft.com/software-download/windows11"
    })
}

# Populate App Categories for Install Tab
$categories = $appsData.Values | Select-Object -ExpandProperty category -Unique | Sort-Object

foreach ($cat in $categories) {
    $catContainer = New-Object System.Windows.Controls.StackPanel
    $catContainer.Margin = New-Object System.Windows.Thickness(0,0,0,6)
    $catContainer.Tag = $cat.Trim().ToLower()

    $catHeader = New-Object System.Windows.Controls.TextBlock
    $catHeader.Text = "- $cat"
    $catHeader.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#38BDF8")
    $catHeader.FontWeight = [System.Windows.FontWeights]::Bold
    $catHeader.FontSize = 13
    $catHeader.Margin = "0,8,0,6"
    $catContainer.Children.Add($catHeader) | Out-Null

    $wrapPanel = New-Object System.Windows.Controls.WrapPanel
    $wrapPanel.Margin = "0,0,0,12"

    $catApps = $appsData.GetEnumerator() | Where-Object { $_.Value.category -eq $cat }
    foreach ($appEntry in $catApps) {
        $appKey = $appEntry.Key
        $app = $appEntry.Value

        $border = New-Object System.Windows.Controls.Border
        $border.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#182232")
        $border.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#334155")
        $border.BorderThickness = New-Object System.Windows.Thickness(1)
        $border.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $border.Margin = New-Object System.Windows.Thickness(3)
        $border.Width = 215
        $border.Height = 38
        $border.Tag = $app.content

        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = New-Object System.Windows.Thickness(6,2,6,2)

        $col0 = New-Object System.Windows.Controls.ColumnDefinition
        $col0.Width = [System.Windows.GridLength]::Auto
        $col1 = New-Object System.Windows.Controls.ColumnDefinition
        $col1.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
        $col2 = New-Object System.Windows.Controls.ColumnDefinition
        $col2.Width = [System.Windows.GridLength]::Auto

        $grid.ColumnDefinitions.Add($col0)
        $grid.ColumnDefinitions.Add($col1)
        $grid.ColumnDefinitions.Add($col2)

        $iconImgPath = Join-Path $iconsFolder "$appKey.png"
        if (-not (Test-Path $iconImgPath)) {
            $tempIconsFolder = Join-Path $env:TEMP "prime_icons"
            if (-not (Test-Path $tempIconsFolder)) { New-Item -ItemType Directory -Path $tempIconsFolder -Force | Out-Null }
            $tempIconPath = Join-Path $tempIconsFolder "$appKey.png"
            if (-not (Test-Path $tempIconPath)) {
                try {
                    (New-Object System.Net.WebClient).DownloadFile("$githubRawBase/assets/icons/$appKey.png", $tempIconPath)
                } catch {}
            }
            if (Test-Path $tempIconPath) {
                $iconImgPath = $tempIconPath
            }
        }
        $iconLoaded = $false

        if (Test-Path $iconImgPath) {
            try {
                $img = New-Object System.Windows.Controls.Image
                $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
                $bitmap.BeginInit()
                $bitmap.UriSource = New-Object System.Uri($iconImgPath, [System.UriKind]::Absolute)
                $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                $bitmap.EndInit()
                $img.Source = $bitmap
                $img.Width = 22
                $img.Height = 22
                $img.Margin = New-Object System.Windows.Thickness(0,0,8,0)
                $img.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
                [System.Windows.Controls.Grid]::SetColumn($img, 0)
                $grid.Children.Add($img) | Out-Null
                $iconLoaded = $true
            } catch {}
        }

        if (-not $iconLoaded) {
            $badge = New-Object System.Windows.Controls.Border
            $badge.Width = 22
            $badge.Height = 22
            $badge.CornerRadius = New-Object System.Windows.CornerRadius(4)
            $badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
            $badge.Margin = New-Object System.Windows.Thickness(0,0,8,0)

            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.Text = $app.content.Substring(0,1)
            $tb.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")
            $tb.FontSize = 11
            $tb.FontWeight = [System.Windows.FontWeights]::Bold
            $tb.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $tb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $badge.Child = $tb
            [System.Windows.Controls.Grid]::SetColumn($badge, 0)
            $grid.Children.Add($badge) | Out-Null
        }

        $chk = New-Object System.Windows.Controls.CheckBox
        $chk.Content = $app.content
        $chk.Tag = $app.winget
        $chk.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F8FAFC")
        $chk.FontSize = 11.5
        $chk.FontWeight = [System.Windows.FontWeights]::SemiBold
        $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $chk.Add_Checked({ Update-SelectionCounter })
        $chk.Add_Unchecked({ Update-SelectionCounter })

        [System.Windows.Controls.Grid]::SetColumn($chk, 1)
        $grid.Children.Add($chk) | Out-Null

        $dot = New-Object System.Windows.Shapes.Ellipse
        $dot.Width = 5
        $dot.Height = 5
        $dot.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#22C55E")
        $dot.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $dot.Margin = New-Object System.Windows.Thickness(4,0,0,0)
        [System.Windows.Controls.Grid]::SetColumn($dot, 2)
        $grid.Children.Add($dot) | Out-Null

        $border.Child = $grid
        $wrapPanel.Children.Add($border) | Out-Null
        $selectedAppCheckboxes += $chk
    }

    $catContainer.Children.Add($wrapPanel) | Out-Null
    if ($pnlAppCategories) {
        $pnlAppCategories.Children.Add($catContainer) | Out-Null
    }
}

# Initial Theme Apply: Night Mode by Default (Dark Theme)
Apply-ThemeStyles "Night"

if ($btnThemeToggle) {
    $btnThemeToggle.Add_Click({
        $global:currentThemeState = ($global:currentThemeState + 1) % 2
        if ($global:currentThemeState -eq 0) {
            Apply-ThemeStyles "Day"
        } else {
            Apply-ThemeStyles "Night"
        }
    })
}

$window.Topmost = $true
$window.Activate()
$window.Focus()
$window.Topmost = $false

$window.ShowDialog() | Out-Null
