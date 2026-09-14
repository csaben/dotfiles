#!/usr/bin/env sh
set -eu

BASE_URL="${DOTFILES_BASE_URL:-https://raw.githubusercontent.com/csaben/dotfiles/main}"

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "Root access or sudo is required to install tmux." >&2
    exit 1
  fi
}

install_tmux() {
  if command -v tmux >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
    return
  fi

  case "$(uname -s)" in
    Darwin)
      command -v brew >/dev/null 2>&1 || {
        echo "Homebrew is required to install tmux on macOS." >&2
        exit 1
      }
      brew install tmux git
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        as_root apt-get update
        as_root apt-get install -y tmux git
      elif command -v dnf >/dev/null 2>&1; then
        as_root dnf install -y tmux git
      elif command -v yum >/dev/null 2>&1; then
        as_root yum install -y tmux git
      elif command -v pacman >/dev/null 2>&1; then
        as_root pacman -S --needed --noconfirm tmux git
      elif command -v zypper >/dev/null 2>&1; then
        as_root zypper --non-interactive install tmux git
      elif command -v apk >/dev/null 2>&1; then
        as_root apk add tmux git
      else
        echo "No supported package manager found." >&2
        exit 1
      fi
      ;;
    *)
      echo "Unsupported platform: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

install_tmux

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT HUP INT TERM
curl -fsSL "$BASE_URL/tmux/tmux.conf" -o "$staging/tmux.conf"

stamp="$(date +%Y%m%d-%H%M%S)"
if [ -f "$HOME/.tmux.conf" ]; then
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup-$stamp"
fi
install -m 0644 "$staging/tmux.conf" "$HOME/.tmux.conf"

tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d "$tpm_dir" ]; then
  mkdir -p "$HOME/.tmux/plugins"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

"$tpm_dir/bin/install_plugins"
if tmux list-sessions >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf"
fi

echo "Installed tmux with Alt+b as the prefix and installed its plugins."
