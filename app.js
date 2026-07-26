/* ================================================================
   PRIME UTILITIES - WINUTIL DYNAMIC COLORFUL ICON CONTROLLER
   ================================================================ */

document.addEventListener('DOMContentLoaded', async () => {
  const pnlAppCategories = document.getElementById('pnl-app-categories');
  const btnInstallSelected = document.getElementById('btn-install-selected');
  const btnUninstallSelected = document.getElementById('btn-uninstall-selected');
  const btnUpgradeAll = document.getElementById('btn-upgrade-all');
  const btnShowInstalled = document.getElementById('btn-show-installed');
  const btnCollapseAll = document.getElementById('btn-collapse-all');
  const btnExpandAll = document.getElementById('btn-expand-all');
  const btnClearSel = document.getElementById('btn-clear-sel');
  const btnSelCount = document.getElementById('btn-sel-count');
  const searchInput = document.getElementById('app-search');
  const filterChips = document.querySelectorAll('.filter-chip');
  const navTabs = document.querySelectorAll('.nav-tab');
  const filtersBar = document.getElementById('filters-bar');
  const sidebarInstall = document.getElementById('sidebar-install');
  const terminalOutput = document.getElementById('terminal-output');

  // SimpleIcons Brand Logo Mapper
  const iconSlugMap = {
    '1password': '1password',
    '7zip': '7zip',
    'adobe': 'adobeacrobatreader',
    'advancedip': 'advancedipscanner',
    'aimp': 'aimp',
    'angryipscanner': 'angryipscanner',
    'anydesk': 'anydesk',
    'audacity': 'audacity',
    'autoruns': 'microsoft',
    'autohotkey': 'autohotkey',
    'bitwarden': 'bitwarden',
    'blender': 'blender',
    'brave': 'brave',
    'bulkcrapuninstaller': 'bulkcrapuninstaller',
    'calibre': 'calibre',
    'cemu': 'cemu',
    'chatgpt': 'openai',
    'chatterino': 'chatterino',
    'chrome': 'googlechrome',
    'chromium': 'chromium',
    'cinebenchr23': 'maxon',
    'claude': 'anthropic',
    'claude-code': 'anthropic',
    'cmake': 'cmake',
    'codex': 'openai',
    'cpuz': 'cpu',
    'crystaldiskinfo': 'crystaldiskinfo',
    'crystaldiskmark': 'crystaldiskmark',
    'cursor': 'cursor',
    'ddu': 'wagnardsoft',
    'discord': 'discord',
    'dismtools': 'microsoft',
    'dorion': 'discord',
    'dotnet6': 'dotnet',
    'dotnet8': 'dotnet',
    'dotnet9': 'dotnet',
    'dropbox': 'dropbox',
    'eaapp': 'ea',
    'eartrumpet': 'windows',
    'edge': 'microsoftedge',
    'element': 'element',
    'epicgames': 'epicgames',
    'everything': 'windows',
    'firefox': 'firefox',
    'firefox-esr': 'firefox',
    'floorp': 'firefox',
    'git': 'git',
    'github-desktop': 'github',
    'gog-galaxy': 'gogdotcom',
    'go': 'go',
    'gpuz': 'techpowerup',
    'handbrake': 'handbrake',
    'heroic': 'heroicgameslauncher',
    'hwmonitor': 'cpuid',
    'jetbrains-toolbox': 'jetbrains',
    'lazygit': 'git',
    'librewolf': 'librewolf',
    'mullvad-browser': 'mullvad',
    'neovim': 'neovim',
    'nodejs': 'nodedotjs',
    'nodejs-lts': 'nodedotjs',
    'ntlite': 'windows',
    'obs': 'obsstudio',
    'oh-my-posh': 'ohmyposh',
    'paint.net': 'paint-dot-net',
    'playnite': 'playnite',
    'pnpm': 'pnpm',
    'powertoys': 'microsoft',
    'proton-mail': 'protonmail',
    'python': 'python',
    'qtox': 'tox',
    'rufus': 'rufus',
    'sharex': 'sharex',
    'shotcut': 'shotcut',
    'signal': 'signal',
    'slack': 'slack',
    'steam': 'steam',
    'teams': 'microsoftteams',
    'teamspeak': 'teamspeak',
    'telegram': 'telegram',
    'thunderbird': 'thunderbird',
    'tor-browser': 'torbrowser',
    'ubisoft-connect': 'ubisoft',
    'ungoogled-chromium': 'chromium',
    'vesktop': 'discord',
    'viber': 'viber',
    'vivaldi': 'vivaldi',
    'vlc': 'vlcmediaplayer',
    'vscode': 'visualstudiocode',
    'waterfox': 'waterfox',
    'whatsapp': 'whatsapp',
    'wireshark': 'wireshark',
    'winrar': 'winrar',
    'zen-browser': 'zenbrowser',
    'zoom': 'zoom'
  };

  let appsData = {};

  try {
    const res = await fetch('config/applications.json');
    appsData = await res.json();
  } catch (e) {
    console.error('Could not fetch applications.json');
  }

  // Populate Categories and App Cards with Authentic Colorful Brand Logos
  if (pnlAppCategories && Object.keys(appsData).length > 0) {
    pnlAppCategories.innerHTML = '';
    const categories = [...new Set(Object.values(appsData).map(a => a.category))].sort();

    categories.forEach(cat => {
      const block = document.createElement('div');
      block.className = 'category-block';

      const catHeader = document.createElement('div');
      catHeader.className = 'cat-header';
      catHeader.innerText = `- ${cat}`;
      block.appendChild(catHeader);

      const grid = document.createElement('div');
      grid.className = 'app-grid';

      const catApps = Object.entries(appsData).filter(([_, app]) => app.category === cat);

      catApps.forEach(([key, app]) => {
        const item = document.createElement('div');
        item.className = 'app-item';
        item.setAttribute('data-appid', app.winget);

        const slug = iconSlugMap[key] || 'windows';
        const iconUrl = `https://cdn.simpleicons.org/${slug}`;

        item.innerHTML = `
          <img src="${iconUrl}" class="app-icon-img" alt="${app.content}" onerror="this.src='https://cdn.simpleicons.org/windows'">
          <span class="app-item-name">${app.content}</span>
          <div class="app-item-dot"></div>
        `;

        item.addEventListener('click', () => {
          item.classList.toggle('selected');
          updateSelectedCount();
        });

        grid.appendChild(item);
      });

      block.appendChild(grid);
      pnlAppCategories.appendChild(block);
    });
  }

  // Top Tabs Switcher
  navTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      navTabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const targetTab = tab.getAttribute('data-tab');
      document.querySelectorAll('.tab-view').forEach(view => {
        view.classList.remove('active');
      });

      const targetView = document.getElementById(`view-${targetTab}`);
      if (targetView) targetView.classList.add('active');

      if (targetTab === 'tab-install') {
        if (filtersBar) filtersBar.style.display = 'flex';
        if (sidebarInstall) sidebarInstall.style.display = 'flex';
      } else {
        if (filtersBar) filtersBar.style.display = 'none';
        if (sidebarInstall) sidebarInstall.style.display = 'none';
      }
    });
  });

  // Clear Selection
  btnClearSel?.addEventListener('click', () => {
    document.querySelectorAll('.app-item').forEach(item => item.classList.remove('selected'));
    updateSelectedCount();
    logConsole("[SELECTION] Cleared all selected applications.");
  });

  // Collapse / Expand All
  btnCollapseAll?.addEventListener('click', () => {
    document.querySelectorAll('.app-grid').forEach(g => g.style.display = 'none');
    logConsole("[VIEW] Collapsed all application categories.");
  });

  btnExpandAll?.addEventListener('click', () => {
    document.querySelectorAll('.app-grid').forEach(g => g.style.display = 'grid');
    logConsole("[VIEW] Expanded all application categories.");
  });

  // Filter Chips
  filterChips.forEach(chip => {
    chip.addEventListener('click', () => {
      filterChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');

      const filterText = chip.innerText.toLowerCase();
      const catBlocks = document.querySelectorAll('.category-block');

      catBlocks.forEach(block => {
        const catHeader = block.querySelector('.cat-header')?.innerText.toLowerCase() || '';
        if (filterText === 'all' || catHeader.includes(filterText)) {
          block.style.display = 'flex';
        } else {
          block.style.display = 'none';
        }
      });
    });
  });

  // Search Filter
  searchInput?.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    document.querySelectorAll('.app-item').forEach(item => {
      const name = item.querySelector('.app-item-name')?.innerText.toLowerCase() || '';
      if (name.includes(query)) {
        item.style.display = 'flex';
      } else {
        item.style.display = 'none';
      }
    });
  });

  // Update Selection Count
  function updateSelectedCount() {
    const count = document.querySelectorAll('.app-item.selected').length;
    if (btnSelCount) btnSelCount.innerText = `Selected Apps: ${count}`;
  }

  // Console Logging
  function logConsole(msg) {
    const time = new Date().toLocaleTimeString();
    if (terminalOutput) {
      terminalOutput.innerText += `\n[${time}] ${msg}`;
      terminalOutput.scrollTop = terminalOutput.scrollHeight;
    }
  }

  // Helper for invoking backend script commands
  async function runScriptCommand(title, script) {
    logConsole(`[ACTION] Executing: ${title}`);
    try {
      const response = await fetch('/api/run-command', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ script })
      });
      if (response.ok) {
        const result = await response.json();
        logConsole(result.output || `${title} executed successfully.`);
      } else {
        throw new Error(`Server returned HTTP ${response.status}`);
      }
    } catch (e) {
      logConsole(`[ERROR] Server execution failed: ${e.message}`);
    }
  }

  // Install Applications Action
  btnInstallSelected?.addEventListener('click', async () => {
    const selected = Array.from(document.querySelectorAll('.app-item.selected'))
      .map(item => item.getAttribute('data-appid'));

    if (selected.length === 0) {
      alert("Please select at least one application to install.");
      return;
    }

    logConsole(`[INSTALL] Starting WinGet installation for ${selected.length} package(s): ${selected.join(', ')}`);
    const script = `& "$PSScriptRoot/scripts/Install-Apps.ps1" -AppIds @(${selected.map(id => `'${id}'`).join(', ')})`;
    await runScriptCommand("Install Applications", script);
  });

  // Uninstall Applications Action
  btnUninstallSelected?.addEventListener('click', async () => {
    const selected = Array.from(document.querySelectorAll('.app-item.selected'))
      .map(item => item.getAttribute('data-appid'));

    if (selected.length === 0) {
      alert("Please select at least one application to uninstall.");
      return;
    }

    logConsole(`[UNINSTALL] Starting WinGet uninstallation for ${selected.length} package(s): ${selected.join(', ')}`);
    const script = `foreach ($app in @(${selected.map(id => `'${id}'`).join(', ')})) { winget uninstall --id $app --silent --accept-source-agreements }`;
    await runScriptCommand("Uninstall Applications", script);
  });

  // Upgrade All Applications Action
  btnUpgradeAll?.addEventListener('click', async () => {
    await runScriptCommand("Upgrade All Packages", "winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements");
  });

  // Show Installed Apps Action
  btnShowInstalled?.addEventListener('click', async () => {
    await runScriptCommand("Installed Packages List", "winget list");
  });

  // System Repairs Tools Event Listeners
  document.getElementById('btn-fix-sys')?.addEventListener('click', () => {
    runScriptCommand("System Corruption Scan (SFC & DISM)", '& "$PSScriptRoot/scripts/System-Repairs.ps1" -RunSFC -RunDISM');
  });

  document.getElementById('btn-fix-net')?.addEventListener('click', () => {
    runScriptCommand("Network & DNS Reset", '& "$PSScriptRoot/scripts/System-Repairs.ps1" -ResetNetwork -FlushDNS');
  });

  document.getElementById('btn-fix-wu')?.addEventListener('click', () => {
    runScriptCommand("Windows Update Reset", '& "$PSScriptRoot/scripts/System-Repairs.ps1" -ResetWindowsUpdateCache');
  });

  document.getElementById('btn-fix-winget')?.addEventListener('click', () => {
    runScriptCommand("Reinstall WinGet", 'Invoke-RestMethod -Uri https://raw.githubusercontent.com/marticliment/Winget-AutoUpdate/main/Winget-AutoUpdate/winget-install.ps1 | Invoke-Expression');
  });

  document.getElementById('btn-fix-ntp')?.addEventListener('click', () => {
    runScriptCommand("NTP Server Resync", 'w32tm /config /syncfromflags:manual /manualpeerlist:"pool.ntp.org" /syncfromflags:MANUAL; w32tm /config /update; w32tm /resync');
  });

  document.getElementById('btn-enable-ssh')?.addEventListener('click', () => {
    runScriptCommand("Enable OpenSSH Server", 'Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; Start-Service sshd; Set-Service -Name sshd -StartupType Automatic');
  });

  // Tweaks Tab Event Listeners
  document.getElementById('btn-run-tweaks')?.addEventListener('click', () => {
    runScriptCommand("Apply Windows Tweaks", '& "$PSScriptRoot/scripts/Apply-Tweaks.ps1" -DisableTelemetry -DisableBingSearch -DisableGameDVR -RemoveBloatware -OptimizeServices -FixMouseAcceleration');
  });

  document.getElementById('btn-undo-tweaks')?.addEventListener('click', () => {
    runScriptCommand("Undo Tweaks", 'Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" -Name "AllowTelemetry" -Value 1 -Force');
  });

  document.getElementById('btn-appx-remove')?.addEventListener('click', () => {
    runScriptCommand("AppX Bloatware Removal", '& "$PSScriptRoot/scripts/Apply-Tweaks.ps1" -RemoveBloatware');
  });

  document.getElementById('btn-enable-ult-perf')?.addEventListener('click', () => {
    runScriptCommand("Enable Ultimate Performance", 'powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61');
  });

  document.getElementById('btn-oo-shutup')?.addEventListener('click', () => {
    runScriptCommand("Run O&O ShutUp10++", '$ooPath = Join-Path $env:TEMP "OOSHUTUP10.exe"; (New-Object System.Net.WebClient).DownloadFile("https://dl5.oo-software.com/files/ooshutup10/OOSHUTUP10.exe", $ooPath); Start-Process $ooPath');
  });

  // Updates Tab Event Listeners
  document.getElementById('btn-wu-recommended')?.addEventListener('click', () => {
    runScriptCommand("Apply Recommended Updates Profile", '& "$PSScriptRoot/scripts/Manage-Updates.ps1" -Mode Recommended');
  });

  document.getElementById('btn-wu-default')?.addEventListener('click', () => {
    runScriptCommand("Restore Default Updates Profile", '& "$PSScriptRoot/scripts/Manage-Updates.ps1" -Mode Default');
  });

  document.getElementById('btn-wu-disable')?.addEventListener('click', () => {
    runScriptCommand("Disable Updates Profile", '& "$PSScriptRoot/scripts/Manage-Updates.ps1" -Mode Disable');
  });

  // Control Panel Shortcuts
  const panelCmds = {
    'panel-control': 'control.exe',
    'panel-net': 'ncpa.cpl',
    'panel-power': 'powercfg.cpl',
    'panel-appwiz': 'appwiz.cpl',
    'panel-sysdm': 'sysdm.cpl',
    'panel-firewall': 'firewall.cpl'
  };

  Object.entries(panelCmds).forEach(([btnId, cmd]) => {
    document.getElementById(btnId)?.addEventListener('click', () => {
      runScriptCommand(`Open ${btnId}`, `Start-Process ${cmd}`);
    });
  });

  updateSelectedCount();
});
