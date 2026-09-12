#!/usr/bin/env sh
set -eu

BASE_URL="${DOTFILES_BASE_URL:-https://raw.githubusercontent.com/csaben/dotfiles/main}"

install_zed() {
  case "$(uname -s)" in
    Linux)
      if ! command -v zed >/dev/null 2>&1 && ! command -v zeditor >/dev/null 2>&1; then
        curl -fsSL https://zed.dev/install.sh | sh
      fi
      ;;
    Darwin)
      if ! command -v zed >/dev/null 2>&1 && [ ! -d /Applications/Zed.app ]; then
        command -v brew >/dev/null 2>&1 || {
          echo "Homebrew is required to install Zed on macOS." >&2
          exit 1
        }
        brew install --cask zed
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      if ! command -v winget.exe >/dev/null 2>&1; then
        echo "winget is required to install Zed on Windows." >&2
        exit 1
      fi
      winget.exe install -e --id ZedIndustries.Zed \
        --accept-package-agreements --accept-source-agreements --silent
      ;;
    *)
      echo "Unsupported platform: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

config_dir() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      if [ -n "${APPDATA:-}" ]; then
        printf '%s/Zed\n' "$APPDATA"
      else
        printf '%s/AppData/Roaming/Zed\n' "$HOME"
      fi
      ;;
    *) printf '%s/.config/zed\n' "$HOME" ;;
  esac
}

install_config() {
  destination="${ZED_CONFIG_DIR:-$(config_dir)}"
  staging="$(mktemp -d)"
  trap 'rm -rf "$staging"' EXIT HUP INT TERM

  curl -fsSL "$BASE_URL/zed/settings.json" -o "$staging/settings.json"
  curl -fsSL "$BASE_URL/zed/keymap.json" -o "$staging/keymap.json"

  mkdir -p "$destination"
  stamp="$(date +%Y%m%d-%H%M%S)"
  for file in settings.json keymap.json; do
    if [ -f "$destination/$file" ]; then
      cp "$destination/$file" "$destination/$file.backup-$stamp"
    fi
    install -m 0644 "$staging/$file" "$destination/$file"
  done

  echo "Installed Zed config in $destination"
}

install_zed
install_config

