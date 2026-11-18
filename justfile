# Dotfiles management
# Usage: just <recipe>  (see `just --list`)

default:
    @just --list

# Full bootstrap: packages + stow + services (same as ./install.sh)
install:
    ./install.sh

# Full bootstrap with system setup and non-pacman tools
bootstrap:
    ./install.sh --all

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

# Install the screen-lock PAM stack + faillock policy (asks for sudo)
lock-pam:
    ./install.sh --pam

# Inspect Thunderbolt/USB4 devices, connected displays, and the USB tree
dock-check:
    #!/usr/bin/env bash
    set -uo pipefail

    echo "== Thunderbolt =="
    if command -v boltctl >/dev/null 2>&1; then
        boltctl list 2>/dev/null | grep -E "^\s*\*|status:|authflags|stored" || echo "  (no Thunderbolt devices)"
    else
        echo "  boltctl not installed"
    fi

    echo "== Connected displays =="
    for c in /sys/class/drm/card*-*; do
        [[ -e "$c/status" ]] || continue
        [[ "$(cat "$c/status" 2>/dev/null)" == "connected" ]] && echo "  $(basename "$c")"
    done

    echo "== USB tree =="
    for d in /sys/bus/usb/devices/*; do
        [[ -e "$d/idVendor" ]] || continue
        printf "  %-10s %s:%s  %s\n" \
            "$(basename "$d")" \
            "$(cat "$d/idVendor" 2>/dev/null)" \
            "$(cat "$d/idProduct" 2>/dev/null)" \
            "$(cat "$d/product" 2>/dev/null)"
    done

    echo
    echo "If a dock keyboard/mouse is missing above, replug the Thunderbolt/USB-C"
    echo "cable and re-run: the dock's USB2 sideband can fail to re-enumerate"
    echo "independently of USB3 and the displays."

# Re-apply the Brain Shell UI-scale patch after updating the checkout
patch-brainshell:
    #!/usr/bin/env bash
    set -euo pipefail
    target="${BRAIN_SHELL_DIR:-$HOME/.local/src/Brain_Shell}"
    patch="{{justfile_directory()}}/patches/brain-shell-uiscale.patch"

    if [[ ! -d "$target/.git" ]]; then
        echo "Brain Shell checkout not found at: $target" >&2
        exit 1
    fi
    if [[ ! -f "$patch" ]]; then
        echo "Patch file not found: $patch" >&2
        exit 1
    fi

    if git -C "$target" apply --check --reverse "$patch" 2>/dev/null; then
        echo "Already applied: $target"
        exit 0
    fi
    if ! git -C "$target" apply --check "$patch" 2>/dev/null; then
        echo "Patch does not apply cleanly to $target." >&2
        echo "Upstream may have changed; inspect $patch." >&2
        exit 1
    fi

    git -C "$target" apply "$patch"
    echo "Applied UI-scale patch to $target"
    echo "Restart Brain Shell: pkill -x quickshell && quickshell -p \"$target\" &"

# Verify the system matches the repo (symlinks, packages, services)
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0
    ok()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
    bad() { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
    warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }

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

    echo "== Screen lock =="
    if cmp -s system/pam.d/hyprlock /etc/pam.d/hyprlock; then
      ok "hyprlock PAM stack matches the repo (no pam_faillock)"
    else
      bad "/etc/pam.d/hyprlock differs from system/pam.d/hyprlock (run: just lock-pam)"
    fi
    if [[ "$(faillock --user "$USER" 2>/dev/null | tail -n +3 | grep -c .)" -gt 0 ]]; then
      warn "faillock tally has entries (clear with: sudo faillock --user $USER --reset)"
    else
      ok "faillock tally empty"
    fi
    idle_count=$(pgrep -cx hypridle 2>/dev/null || true)
    if [[ "${idle_count:-0}" -gt 1 ]]; then
      bad "$idle_count hypridle instances running (expected 1; log out/in)"
    else
      ok "single hypridle instance"
    fi

    echo "== Shell =="
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$(command -v zsh)" ]]; then
      ok "login shell is zsh"
    else
      bad "login shell is not zsh (run: chsh -s $(command -v zsh))"
    fi

    echo "== Tools =="
    has_tool() {
      local t="$1"
      command -v "$t" >/dev/null 2>&1 || \
        [ -x "$HOME/.local/bin/$t" ] || \
        [ -x "$HOME/.opencode/bin/$t" ] || \
        [ -x "$HOME/.cargo/bin/$t" ]
    }
    for tool in stow yay just; do
      has_tool "$tool" && ok "$tool" || bad "$tool missing"
    done
    for tool in opencode uv rustup cargo; do
      has_tool "$tool" && ok "$tool" || bad "$tool missing (run: ./install.sh --tools)"
    done
    for tool in tuxedo sqlit; do
      has_tool "$tool" && ok "$tool" || warn "$tool missing (optional; run: ./install.sh --tools)"
    done
    [ -s "$HOME/.nvm/nvm.sh" ] && ok "nvm" || warn "nvm missing (optional; run: ./install.sh --tools)"

    echo ""
    if [[ $fail -eq 0 ]]; then
      echo "All good."
    else
      echo "Issues found."
      exit 1
    fi