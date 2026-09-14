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

## PowerToys keyboard shortcuts

Install PowerToys and configure these global Keyboard Manager shortcuts:

- `Alt+Enter` -> `F11`
- `Alt+S` -> `Win+Shift+S`

```powershell
irm https://raw.githubusercontent.com/csaben/dotfiles/main/install-powertoys.ps1 | iex
```

Existing PowerToys and Keyboard Manager settings are preserved as timestamped
backups before they are changed. `DOTFILES_BASE_URL` can also override the
source location for this installer.

## tmux and psmux

On Windows, install native psmux and Clark's matching configuration:

```powershell
irm https://raw.githubusercontent.com/csaben/dotfiles/main/tmux/install.ps1 | iex
```

On Linux or macOS, install tmux, TPM, plugins, and the native configuration:

```sh
curl -fsSL https://raw.githubusercontent.com/csaben/dotfiles/main/tmux/install.sh | sh
```

Both configurations use `Alt+b` as the prefix and preserve an existing config
as a timestamped backup. Set `DOTFILES_BASE_URL` to override their source.
