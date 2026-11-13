# Dotfiles management
# Usage: just <recipe>  (see `just --list`)

default:
    @just --list

# Full bootstrap: packages + stow + services (same as ./install.sh)
install:
    ./install.sh

# Re-link all stow packages
stow:
    stow -R -d . -t ~/.config config
    stow -R -d . -t ~ home
    stow -R -d . -t ~/.local local-bin

# Pull latest dotfiles and re-link
update:
    git pull --ff-only
    just stow

# Update all packages (official + AUR)
packages:
    yay -Syu

# Validate configs load cleanly
check:
    hyprctl configerrors
    nvim --headless -c 'qa' 2>&1 | head -5

# Verify the system matches the repo (symlinks, packages, services)
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0
    ok()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
    bad() { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }

    echo "== Git =="
    if [[ -n "$(git status --porcelain)" ]]; then
      bad "working tree has uncommitted changes"
    else
      ok "working tree clean"
    fi
    git fetch -q origin 2>/dev/null || true
    if [[ "$(git rev-parse HEAD)" != "$(git rev-parse @{u} 2>/dev/null)" ]]; then
      bad "local branch differs from origin (run: just update)"
    else
      ok "up to date with origin"
    fi

    echo "== Symlinks =="
    for dir in config/*/; do
      name=$(basename "$dir")
      [[ -L "$HOME/.config/$name" ]] && ok "~/.config/$name" || bad "~/.config/$name missing"
    done
    for f in config/*; do
      [[ -f "$f" ]] || continue
      name=$(basename "$f")
      [[ -L "$HOME/.config/$name" ]] && ok "~/.config/$name" || bad "~/.config/$name missing"
    done
    for f in .zshrc .bashrc .profile .gitconfig; do
      [[ -L "$HOME/$f" ]] && ok "~/$f" || bad "~/$f missing"
    done
    for entry in local-bin/bin/*; do
      name=$(basename "$entry")
      [[ -L "$HOME/.local/bin/$name" ]] && ok "~/.local/bin/$name" || bad "~/.local/bin/$name missing"
    done

    echo "== Packages =="
    missing=0
    while read -r pkg; do
      [[ -z "$pkg" || "$pkg" == \#* ]] && continue
      if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        bad "package not installed: $pkg"
        missing=1
      fi
    done < packages/official.txt
    while read -r pkg; do
      [[ -z "$pkg" || "$pkg" == \#* ]] && continue
      if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        bad "package not installed: $pkg"
        missing=1
      fi
    done < packages/aur.txt
    [[ $missing -eq 0 ]] && ok "all packages installed"

    echo "== Services =="
    for svc in voxtype cliphist-wipe; do
      if systemctl --user is-enabled "$svc" >/dev/null 2>&1; then
        ok "user service enabled: $svc"
      else
        bad "user service not enabled: $svc"
      fi
    done

    echo "== Shell =="
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$(command -v zsh)" ]]; then
      ok "login shell is zsh"
    else
      bad "login shell is not zsh (run: chsh -s $(command -v zsh))"
    fi

    echo "== Tools =="
    for tool in opencode uv stow yay just; do
      command -v "$tool" >/dev/null 2>&1 && ok "$tool" || bad "$tool missing"
    done

    echo ""
    if [[ $fail -eq 0 ]]; then
      echo "All good."
    else
      echo "Issues found."
      exit 1
    fi