$iconDir = Join-Path $PSScriptRoot "..\assets\icons"
if (-not (Test-Path $iconDir)) { New-Item -ItemType Directory -Force -Path $iconDir | Out-Null }

$domainMap = @{
    '1password' = '1password.com';
    '7zip' = '7-zip.org';
    'adobe' = 'adobe.com';
    'advancedip' = 'advanced-ip-scanner.com';
    'aimp' = 'aimp.ru';
    'angryipscanner' = 'angryip.org';
    'anydesk' = 'anydesk.com';
    'audacity' = 'audacityteam.org';
    'autoruns' = 'microsoft.com';
    'autohotkey' = 'autohotkey.com';
    'bitwarden' = 'bitwarden.com';
    'blender' = 'blender.org';
    'brave' = 'brave.com';
    'bulkcrapuninstaller' = 'bcuninstaller.com';
    'calibre' = 'calibre-ebook.com';
    'cemu' = 'cemu.info';
    'chatgpt' = 'chatgpt.com';
    'chatterino' = 'chatterino.com';
    'chrome' = 'google.com';
    'chromium' = 'chromium.org';
    'cinebenchr23' = 'maxon.net';
    'claude' = 'claude.ai';
    'claude-code' = 'claude.ai';
    'cmake' = 'cmake.org';
    'codex' = 'openai.com';
    'cpuz' = 'cpuid.com';
    'crystaldiskinfo' = 'crystalmark.info';
    'crystaldiskmark' = 'crystalmark.info';
    'cursor' = 'cursor.com';
    'ddu' = 'wagnardsoft.com';
    'discord' = 'discord.com';
    'dismtools' = 'github.com';
    'dorion' = 'github.com';
    'dotnet6' = 'microsoft.com';
    'dotnet8' = 'microsoft.com';
    'dotnet9' = 'microsoft.com';
    'dropbox' = 'dropbox.com';
    'eaapp' = 'ea.com';
    'eartrumpet' = 'microsoft.com';
    'edge' = 'microsoft.com';
    'element' = 'element.io';
    'epicgames' = 'epicgames.com';
    'everything' = 'voidtools.com';
    'firefox' = 'mozilla.org';
    'firefox-esr' = 'mozilla.org';
    'floorp' = 'ablaze.one';
    'git' = 'git-scm.com';
    'github-desktop' = 'github.com';
    'gog-galaxy' = 'gog.com';
    'go' = 'go.dev';
    'gpuz' = 'techpowerup.com';
    'handbrake' = 'handbrake.fr';
    'heroic' = 'heroicgameslauncher.com';
    'hwmonitor' = 'cpuid.com';
    'jetbrains-toolbox' = 'jetbrains.com';
    'lazygit' = 'github.com';
    'librewolf' = 'librewolf.net';
    'mullvad-browser' = 'mullvad.net';
    'neovim' = 'neovim.io';
    'nodejs' = 'nodejs.org';
    'nodejs-lts' = 'nodejs.org';
    'ntlite' = 'ntlite.com';
    'obs' = 'obsproject.com';
    'oh-my-posh' = 'ohmyposh.dev';
    'paint.net' = 'getpaint.net';
    'playnite' = 'playnite.link';
    'pnpm' = 'pnpm.io';
    'powertoys' = 'microsoft.com';
    'proton-mail' = 'proton.me';
    'python' = 'python.org';
    'qtox' = 'qtox.github.io';
    'rufus' = 'rufus.ie';
    'sharex' = 'getsharex.com';
    'shotcut' = 'shotcut.org';
    'signal' = 'signal.org';
    'slack' = 'slack.com';
    'steam' = 'steampowered.com';
    'teams' = 'microsoft.com';
    'teamspeak' = 'teamspeak.com';
    'telegram' = 'telegram.org';
    'thunderbird' = 'thunderbird.net';
    'tor-browser' = 'torproject.org';
    'ubisoft-connect' = 'ubisoft.com';
    'ungoogled-chromium' = 'github.com';
    'vesktop' = 'github.com';
    'viber' = 'viber.com';
    'vivaldi' = 'vivaldi.com';
    'vlc' = 'videolan.org';
    'vscode' = 'code.visualstudio.com';
    'waterfox' = 'waterfox.net';
    'whatsapp' = 'whatsapp.com';
    'wireshark' = 'wireshark.org';
    'winrar' = 'rarlab.com';
    'zen-browser' = 'zen-browser.app';
    'zoom' = 'zoom.us'
}

Write-Host "Downloading real 64px PNG brand icons..."
foreach ($appKey in $domainMap.Keys) {
    $domain = $domainMap[$appKey]
    $destFile = Join-Path $iconDir "$appKey.png"
    $url = "https://www.google.com/s2/favicons?domain=$domain&sz=64"
    try {
        Invoke-WebRequest -Uri $url -OutFile $destFile -TimeoutSec 5 -ErrorAction SilentlyContinue
    } catch {}
}
Write-Host "Downloaded real 64px PNG icons into $iconDir"
