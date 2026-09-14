$ErrorActionPreference = 'Stop'

$baseUrl = if ($env:DOTFILES_BASE_URL) {
    $env:DOTFILES_BASE_URL.TrimEnd('/')
} else {
    'https://raw.githubusercontent.com/csaben/dotfiles/main'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install App Installer from the Microsoft Store and try again.'
}

winget install -e --id Microsoft.PowerToys `
    --accept-package-agreements --accept-source-agreements --silent
if ($LASTEXITCODE -ne 0) {
    throw "PowerToys installation failed with exit code $LASTEXITCODE"
}

# PowerToys can overwrite its settings during shutdown, so stop it before copying.
Get-Process -Name 'PowerToys*' -ErrorAction SilentlyContinue |
    Stop-Process -Force -ErrorAction Stop

$powerToysDir = Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys'
$keyboardManagerDir = Join-Path $powerToysDir 'Keyboard Manager'
New-Item -ItemType Directory -Force -Path $keyboardManagerDir | Out-Null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($file in @('default.json', 'settings.json')) {
    $destination = Join-Path $keyboardManagerDir $file
    if (Test-Path -LiteralPath $destination) {
        Copy-Item -LiteralPath $destination -Destination "$destination.backup-$stamp"
    }
    Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/powertoys/$file" -OutFile $destination
}

# Explicitly enable Keyboard Manager while preserving all other PowerToys settings.
$mainSettingsPath = Join-Path $powerToysDir 'settings.json'
if (Test-Path -LiteralPath $mainSettingsPath) {
    Copy-Item -LiteralPath $mainSettingsPath -Destination "$mainSettingsPath.backup-$stamp"
    $mainSettings = Get-Content -Raw -LiteralPath $mainSettingsPath | ConvertFrom-Json
    if (-not $mainSettings.enabled) {
        $mainSettings | Add-Member -MemberType NoteProperty -Name enabled -Value ([pscustomobject]@{})
    }
    if ($null -eq $mainSettings.enabled.'Keyboard Manager') {
        $mainSettings.enabled | Add-Member -MemberType NoteProperty -Name 'Keyboard Manager' -Value $true
    } else {
        $mainSettings.enabled.'Keyboard Manager' = $true
    }
    $mainSettings | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $mainSettingsPath -Encoding utf8
}

$powerToysExe = @(
    (Join-Path $env:ProgramFiles 'PowerToys\PowerToys.exe')
    (Join-Path $env:LOCALAPPDATA 'PowerToys\PowerToys.exe')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if ($powerToysExe) {
    Start-Process -FilePath $powerToysExe
}

Write-Host 'Installed PowerToys and configured Alt+Enter -> F11 and Alt+S -> Win+Shift+S.'
