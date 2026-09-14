$ErrorActionPreference = 'Stop'

$baseUrl = if ($env:DOTFILES_BASE_URL) {
    $env:DOTFILES_BASE_URL.TrimEnd('/')
} else {
    'https://raw.githubusercontent.com/csaben/dotfiles/main'
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install App Installer from the Microsoft Store and try again.'
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is required to install the psmux plugin manager.'
}

if (-not (Get-Command psmux -ErrorAction SilentlyContinue)) {
    winget install -e --id marlocarlo.psmux `
        --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        throw "psmux installation failed with exit code $LASTEXITCODE"
    }
}

$configPath = Join-Path $env:USERPROFILE '.psmux.conf'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
if (Test-Path -LiteralPath $configPath) {
    Copy-Item -LiteralPath $configPath -Destination "$configPath.backup-$stamp"
}
Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/tmux/psmux.conf" -OutFile $configPath

$pluginRoot = Join-Path $env:USERPROFILE '.psmux\plugins'
$ppmDir = Join-Path $pluginRoot 'ppm'
if (-not (Test-Path -LiteralPath $ppmDir)) {
    $staging = Join-Path ([System.IO.Path]::GetTempPath()) "psmux-plugins-$([guid]::NewGuid())"
    try {
        git clone --depth 1 https://github.com/psmux/psmux-plugins.git $staging
        if ($LASTEXITCODE -ne 0) {
            throw "Cloning psmux plugins failed with exit code $LASTEXITCODE"
        }
        New-Item -ItemType Directory -Force -Path $pluginRoot | Out-Null
        Copy-Item -LiteralPath (Join-Path $staging 'ppm') -Destination $ppmDir -Recurse
    } finally {
        if (Test-Path -LiteralPath $staging) {
            Remove-Item -LiteralPath $staging -Recurse -Force
        }
    }
}

& (Join-Path $ppmDir 'scripts\install_plugins.ps1')

Write-Host 'Installed psmux with Alt+b as the prefix.'
Write-Host 'Start a new psmux server to load the configuration and plugins.'
