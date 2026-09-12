# Clark's dotfiles

Bootstrap Zed and install the personal settings in this repository. Existing
`settings.json` and `keymap.json` files are preserved as timestamped backups.

## Bash (Linux, macOS, or Git Bash)

```sh
curl -fsSL https://raw.githubusercontent.com/csaben/dotfiles/main/install.sh | sh
```

## PowerShell

```powershell
irm https://raw.githubusercontent.com/csaben/dotfiles/main/install.ps1 | iex
```

The Bash installer uses Zed's official installer on Linux, Homebrew on macOS,
and `winget` from Git Bash on Windows. The PowerShell installer uses `winget`.

For a fork or pre-release location, set `DOTFILES_BASE_URL` to the raw directory
containing `install.sh`, `install.ps1`, and `zed/`. Set `ZED_CONFIG_DIR` to
override Zed's normal configuration directory.

