$iconDir = Join-Path $PSScriptRoot "..\assets\icons"
if (-not (Test-Path $iconDir)) { New-Item -ItemType Directory -Force -Path $iconDir | Out-Null }

$iconSlugs = @{
    '1password' = '1password'; '7zip' = '7zip'; 'adobe' = 'adobeacrobatreader'; 'advancedip' = 'advancedipscanner'; 'aimp' = 'aimp'; 'angryipscanner' = 'angryipscanner'; 'anydesk' = 'anydesk'; 'audacity' = 'audacity'; 'autoruns' = 'microsoft'; 'autohotkey' = 'autohotkey'; 'bitwarden' = 'bitwarden'; 'blender' = 'blender'; 'brave' = 'brave'; 'bulkcrapuninstaller' = 'bulkcrapuninstaller'; 'calibre' = 'calibre'; 'cemu' = 'cemu'; 'chatgpt' = 'openai'; 'chatterino' = 'chatterino'; 'chrome' = 'googlechrome'; 'chromium' = 'chromium'; 'cinebenchr23' = 'maxon'; 'claude' = 'anthropic'; 'claude-code' = 'anthropic'; 'cmake' = 'cmake'; 'codex' = 'openai'; 'cpuz' = 'cpu'; 'crystaldiskinfo' = 'crystaldiskinfo'; 'crystaldiskmark' = 'crystaldiskmark'; 'cursor' = 'cursor'; 'ddu' = 'wagnardsoft'; 'discord' = 'discord'; 'dismtools' = 'microsoft'; 'dorion' = 'discord'; 'dotnet6' = 'dotnet'; 'dotnet8' = 'dotnet'; 'dotnet9' = 'dotnet'; 'dropbox' = 'dropbox'; 'eaapp' = 'ea'; 'eartrumpet' = 'windows'; 'edge' = 'microsoftedge'; 'element' = 'element'; 'epicgames' = 'epicgames'; 'everything' = 'windows'; 'firefox' = 'firefox'; 'firefox-esr' = 'firefox'; 'floorp' = 'firefox'; 'git' = 'git'; 'github-desktop' = 'github'; 'gog-galaxy' = 'gogdotcom'; 'go' = 'go'; 'gpuz' = 'techpowerup'; 'handbrake' = 'handbrake'; 'heroic' = 'heroicgameslauncher'; 'hwmonitor' = 'cpuid'; 'jetbrains-toolbox' = 'jetbrains'; 'lazygit' = 'git'; 'librewolf' = 'librewolf'; 'mullvad-browser' = 'mullvad'; 'neovim' = 'neovim'; 'nodejs' = 'nodedotjs'; 'nodejs-lts' = 'nodedotjs'; 'ntlite' = 'windows'; 'obs' = 'obsstudio'; 'oh-my-posh' = 'ohmyposh'; 'paint.net' = 'paint-dot-net'; 'playnite' = 'playnite'; 'pnpm' = 'pnpm'; 'powertoys' = 'microsoft'; 'proton-mail' = 'protonmail'; 'python' = 'python'; 'qtox' = 'tox'; 'rufus' = 'rufus'; 'sharex' = 'sharex'; 'shotcut' = 'shotcut'; 'signal' = 'signal'; 'slack' = 'slack'; 'steam' = 'steam'; 'teams' = 'microsoftteams'; 'teamspeak' = 'teamspeak'; 'telegram' = 'telegram'; 'thunderbird' = 'thunderbird'; 'tor-browser' = 'torbrowser'; 'ubisoft-connect' = 'ubisoft'; 'ungoogled-chromium' = 'chromium'; 'vesktop' = 'discord'; 'viber' = 'viber'; 'vivaldi' = 'vivaldi'; 'vlc' = 'vlcmediaplayer'; 'vscode' = 'visualstudiocode'; 'waterfox' = 'waterfox'; 'whatsapp' = 'whatsapp'; 'wireshark' = 'wireshark'; 'winrar' = 'winrar'; 'zen-browser' = 'zenbrowser'; 'zoom' = 'zoom'
}

Write-Host "Downloading PNG app icons..."
foreach ($appKey in $iconSlugs.Keys) {
    $slug = $iconSlugs[$appKey]
    $destFile = Join-Path $iconDir "$appKey.png"
    $url = "https://cdn.simpleicons.org/$slug"
    try {
        Invoke-WebRequest -Uri $url -OutFile $destFile -TimeoutSec 3 -ErrorAction SilentlyContinue
    } catch {}
}
Write-Host "Downloaded PNG app icons into $iconDir"
