# Prime Utilities - Windows Optimization Suite

![Prime Utilities Banner](https://img.shields.io/badge/Windows-10%2F11-blue?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Prime Utilities** is a comprehensive, modern Windows system utility inspired by Chris Titus Tech's WinUtil (`winutil`). It combines a rich, interactive Web GUI dashboard with safe, modular PowerShell scripts to optimize Windows performance, remove bloatware, install essential applications via WinGet, repair system files, and manage Windows Updates.

---

## 🌟 Key Features

### 1. ⚡ System Tweaks & Debloater
* **Disable Telemetry & Diagnostics**: Halts background data collection and tracking services (`DiagTrack`, `dmwappushservice`).
* **Appx Bloatware Removal**: Uninstalls pre-installed bloatware (Solitaire, News, Weather, 3D Builder, Skype).
* **Start Menu Clean-up**: Disables web/Bing search integration in the Windows search bar.
* **Gaming Optimizations**: Disables Xbox GameDVR background recording and fixes mouse acceleration for raw 1:1 input.
* **Background Service Tuning**: Switches non-essential background services (Maps, Fax, Xbox auth) to manual startup.
* **Presets**: One-click quick activation for *Desktop*, *Gaming*, and *Laptop/Battery* profiles.

### 2. 📦 WinGet Batch App Installer
Multi-select software installer categorized by:
* **Web Browsers**: Chrome, Firefox, Brave.
* **Dev Tools**: VS Code, Git, Node.js, Python 3.11.
* **Utilities & Media**: 7-Zip, VLC, Discord, Visual C++ Redistributable Runtimes.

### 3. 🛠️ Config & System Repairs
* **SFC Scan**: System File Checker (`sfc /scannow`) to repair corrupted system binaries.
* **DISM Repair**: Component Store image cleanup (`dism /online /cleanup-image /restorehealth`).
* **Network Reset**: Full Winsock, TCP/IP stack reset, and DHCP lease release/renewal.
* **DNS Flush**: Instant DNS resolver cache clearing.
* **Windows Update Cache Reset**: Clears `SoftwareDistribution` cache to fix stuck updates.
* **Windows Features**: Enable WSL (Linux Subsystem) & Hyper-V.

### 4. 🔄 Windows Update Control
* **Default**: Standard automatic Windows Update operation.
* **Security Only**: Restricts downloads to critical security patches while excluding driver updates.
* **Pause Updates**: Temporarily pauses all Windows Update checks for 35 days.
* **Defer Upgrades**: Delays annual major feature builds by 365 days.

### 5. 📜 Script Generator & Exporter
Export your customized configuration into a single standalone `.ps1` (PowerShell Script) file that can be copied to a USB flash drive and run on any machine without installing Node.js or web dependencies.

---

## 🚀 How to Run Prime Utilities

### Option A: Launch Web Dashboard via PowerShell (Recommended)
Right-click `Prime-Utilities.ps1` and select **Run with PowerShell** (or run in an elevated PowerShell terminal):
```powershell
Set-ExecutionPolicy Unrestricted -Scope Process
.\Prime-Utilities.ps1
```

### Option B: Run Web Dashboard via Node.js
```bash
npm start
```
Open your web browser and navigate to `http://localhost:3000`.

### Option C: Interactive CLI Mode
```powershell
.\Prime-Utilities.ps1 -CLI
```

---

## 📁 Project File Map

* [`index.html`](file:///d:/CPA%20Tools/Prime%20Utilities/index.html) - Main Web Dashboard UI
* [`style.css`](file:///d:/CPA%20Tools/Prime%20Utilities/style.css) - Dark Glassmorphism Design System
* [`app.js`](file:///d:/CPA%20Tools/Prime%20Utilities/app.js) - Frontend interactivity, preset logic & script generator
* [`server.js`](file:///d:/CPA%20Tools/Prime%20Utilities/server.js) - Local HTTP & PowerShell execution bridge server
* [`Prime-Utilities.ps1`](file:///d:/CPA%20Tools/Prime%20Utilities/Prime-Utilities.ps1) - Master PowerShell launcher script
* [`scripts/Apply-Tweaks.ps1`](file:///d:/CPA%20Tools/Prime%20Utilities/scripts/Apply-Tweaks.ps1) - Windows debloating & performance engine
* [`scripts/Install-Apps.ps1`](file:///d:/CPA%20Tools/Prime%20Utilities/scripts/Install-Apps.ps1) - WinGet batch installer engine
* [`scripts/System-Repairs.ps1`](file:///d:/CPA%20Tools/Prime%20Utilities/scripts/System-Repairs.ps1) - System repairs & network reset engine
* [`scripts/Manage-Updates.ps1`](file:///d:/CPA%20Tools/Prime%20Utilities/scripts/Manage-Updates.ps1) - Windows Update management engine

---

## 🛡️ License & Safety
Distributed under the MIT License. Always create a System Restore Point before running system-wide modifications (enabled by default in Prime Utilities).
