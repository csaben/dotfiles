$ErrorActionPreference = 'Stop'

$baseUrl = if ($env:DOTFILES_BASE_URL) {
    $env:DOTFILES_BASE_URL.TrimEnd('/')
} else {
    'https://raw.githubusercontent.com/csaben/dotfiles/main'
}

if (-not (Get-Command zed -ErrorAction SilentlyContinue) -and
    -not (Test-Path "$env:LOCALAPPDATA\Programs\Zed\Zed.exe")) {
    winget install -e --id ZedIndustries.Zed `
        --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        throw "Zed installation failed with exit code $LASTEXITCODE"
    }
}

$configDir = if ($env:ZED_CONFIG_DIR) {
    $env:ZED_CONFIG_DIR
} else {
    Join-Path $env:APPDATA 'Zed'
}

New-Item -ItemType Directory -Force -Path $configDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

foreach ($file in @('settings.json', 'keymap.json')) {
    $destination = Join-Path $configDir $file
    if (Test-Path -LiteralPath $destination) {
        Copy-Item -LiteralPath $destination -Destination "$destination.backup-$stamp"
    }
    Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/zed/$file" -OutFile $destination
}

Write-Host "Installed Zed config in $configDir"

