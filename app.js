/* ================================================================
   PRIME UTILITIES - WINUTIL DYNAMIC COLORFUL ICON CONTROLLER
   ================================================================ */

document.addEventListener('DOMContentLoaded', async () => {
  const pnlAppCategories = document.getElementById('pnl-app-categories');
  const btnInstallSelected = document.getElementById('btn-install-selected');
  const btnClearSel = document.getElementById('btn-clear-sel');
  const btnSelCount = document.getElementById('btn-sel-count');
  const searchInput = document.getElementById('app-search');
  const filterChips = document.querySelectorAll('.filter-chip');
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

  // Clear Selection
  btnClearSel?.addEventListener('click', () => {
    document.querySelectorAll('.app-item').forEach(item => item.classList.remove('selected'));
    updateSelectedCount();
    logConsole("[SELECTION] Cleared all selected applications.");
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

    try {
      const response = await fetch('/api/run-command', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ script })
      });

      if (response.ok) {
        const result = await response.json();
        logConsole(result.output || "Installation finished.");
      } else {
        throw new Error("Server error");
      }
    } catch (e) {
      logConsole("[SCRIPT GENERATED] Downloading PowerShell script...");
      const blob = new Blob([script], { type: 'text/plain' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'Install-Selected-Apps.ps1';
      a.click();
    }
  });

  updateSelectedCount();
});
