#!/usr/bin/env bash
# =============================================================================
# Dotfiles Bootstrap Script
# =============================================================================
# Usage: cd ~/dotfiles && ./install.sh [--system] [--tools] [--all]
#
#   (no flags)  packages + stow + Brain_Shell + user services
#   --system    configure greetd, enable system services, add groups, firewall zone
#   --tools     install uv, rustup, nvm, opencode, tuxedo, sqlit
#   --all       --system and --tools
#
# What this does:
#   1. Installs yay (AUR helper) if missing
#   2. Ranks mirrors (rate-mirrors) and enables paccache.timer
#   3. Installs all packages from packages/official.txt and packages/aur.txt
#   4. Stows config files into ~/.config with symlinks
#   5. Sets zsh as the login shell
#   6. Clones Brain_Shell to ~/.local/src/Brain_Shell
#   7. Enables user systemd services (voxtype, cliphist-wipe)
#   8. Creates a ~/.opencode-secrets template if missing
#
# Manual steps required after:
#   - Open nvim and run :lua vim.pack.update()
#   - Fill in ~/.opencode-secrets
#   - --system/--tools are opt-in so the default run stays user-level and safe.
# =============================================================================

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; exit 1; }

usage() {
    cat <<'EOF'
Usage: ./install.sh [--system] [--tools] [--all]

  (no flags)  install packages, stow dotfiles, clone Brain_Shell, user services
  --system    configure greetd, enable system services, add groups, firewall zone
  --tools     install uv, rustup, nvm, opencode, tuxedo, sqlit
  --all       --system and --tools

Environment:
  MIRROR_COUNTRY=DE   prioritize mirrors from a country with rate-mirrors
EOF
}

setup_system() {
    log "Configuring greetd..."
    if systemctl cat greetd.service >/dev/null 2>&1 && \
       command -v tuigreet >/dev/null 2>&1 && \
       command -v start-hyprland >/dev/null 2>&1; then
        sudo mkdir -p /etc/greetd
        if [ -f /etc/greetd/config.toml ]; then
            sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.bak
        fi
        sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd start-hyprland --remember --remember-user-session"
user = "$(id -un)"
EOF
        sudo systemctl enable greetd 2>/dev/null || warn "Could not enable greetd"
    else
        warn "greetd/tuigreet/start-hyprland missing; skipping greetd config"
    fi

    log "Enabling fstrim.timer..."
    sudo systemctl enable --now fstrim.timer 2>/dev/null || \
        warn "Could not enable fstrim.timer"

    log "Enabling system services..."
    local svc
    for svc in docker firewalld libvirtd mullvad-daemon; do
        if systemctl cat "$svc.service" >/dev/null 2>&1; then
            sudo systemctl enable --now "$svc.service" 2>/dev/null || \
                warn "Could not enable $svc.service"
        fi
    done

    local groups=()
    if getent group docker >/dev/null 2>&1; then groups+=(docker); fi
    if getent group libvirt >/dev/null 2>&1; then groups+=(libvirt); fi
    if [[ ${#groups[@]} -gt 0 ]]; then
        local group_list
        group_list="$(IFS=,; echo "${groups[*]}")"
        sudo usermod -aG "$group_list" "$(id -un)" 2>/dev/null || \
            warn "Could not add $(id -un) to $group_list"
    fi

    if systemctl is-active --quiet firewalld 2>/dev/null; then
        sudo firewall-cmd --set-default-zone=home 2>/dev/null || \
            warn "Could not set firewalld default zone to home"
    fi
}

install_tools() {
    log "Installing non-pacman tools..."
    export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.cargo/bin:$PATH"

    if ! command -v uv >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/uv" ]; then
        curl -LsSf https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh || \
            warn "uv install failed"
    fi
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v cargo >/dev/null 2>&1 && [ ! -x "$HOME/.cargo/bin/cargo" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
            sh -s -- -y --no-modify-path || warn "rustup install failed"
    fi
    if [ -f "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
    fi

    if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | \
            PROFILE=/dev/null bash || warn "nvm install failed"
    fi

    if ! command -v opencode >/dev/null 2>&1 && [ ! -x "$HOME/.opencode/bin/opencode" ]; then
        curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path || \
            warn "opencode install failed"
    fi

    if command -v cargo >/dev/null 2>&1 && ! command -v tuxedo >/dev/null 2>&1; then
        cargo install tuxedo || warn "tuxedo install failed"
    fi

    if command -v uv >/dev/null 2>&1; then
        uv tool install --with psycopg2-binary sqlit-tui || \
            warn "sqlit install failed (rerun: uv tool install --with psycopg2-binary sqlit-tui)"
    fi
}

# ── Pre-flight checks ──────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && err "Do not run as root. This script uses sudo where needed."
[[ -f "$DOTFILES/packages/official.txt" ]] || err "Missing $DOTFILES/packages/official.txt"
[[ -f "$DOTFILES/packages/aur.txt" ]]      || err "Missing $DOTFILES/packages/aur.txt"
command -v pacman >/dev/null 2>&1 || err "This script requires Arch Linux with pacman"

# ── Options ────────────────────────────────────────────────────────────────
SETUP_SYSTEM=0
INSTALL_TOOLS=0
for arg in "$@"; do
    case "$arg" in
        --system) SETUP_SYSTEM=1 ;;
        --tools)  INSTALL_TOOLS=1 ;;
        --all)    SETUP_SYSTEM=1; INSTALL_TOOLS=1 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; err "Unknown option: $arg" ;;
    esac
done

# ── 1. Install yay (AUR helper) ────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
fi

# ── 1.5 Pacman hygiene: fast mirrors + cache cleanup ───────────────────────
# rate-mirrors ranks the mirrorlist before the big package install below,
# so the install itself uses fast mirrors. Takes a minute or two.
# Prioritize mirrors from your country:  MIRROR_COUNTRY=DE ./install.sh
log "Installing pacman-contrib and rate-mirrors..."
sudo pacman -S --needed --noconfirm pacman-contrib rate-mirrors

log "Ranking mirrors with rate-mirrors (takes a minute or two)..."
if [[ -n "${MIRROR_COUNTRY:-}" ]]; then
    rate-mirrors --entry-country "$MIRROR_COUNTRY" arch | sudo tee /etc/pacman.d/mirrorlist >/dev/null
else
    rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist >/dev/null
fi

log "Enabling paccache.timer (weekly package cache cleanup)..."
sudo systemctl enable --now paccache.timer

# ── 2. Install all packages ─────────────────────────────────────────────────
log "Installing official packages..."
yay -S --needed --noconfirm - < "$DOTFILES/packages/official.txt" 2>/dev/null || \
    warn "Some official packages may have failed (install them manually)"

log "Installing AUR packages..."
yay -S --needed --noconfirm - < "$DOTFILES/packages/aur.txt" 2>/dev/null || \
    warn "Some AUR packages may have failed (install them manually)"

# ── 3. Stow dotfiles ────────────────────────────────────────────────────────
log "Linking config files..."
command -v stow >/dev/null 2>&1 || sudo pacman -S --noconfirm stow

# Fresh installs may not have these directories yet. stow requires the target
# directory to exist, and Brain_Shell is cloned under ~/.local/src.
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/src"

# Remove existing target dirs so stow can create clean symlinks
# (only removes real files/dirs, not existing symlinks — stow handles those)
for dir in "$DOTFILES"/config/*/; do
    name=$(basename "$dir")
    if [ -e "$HOME/.config/$name" ] && [ ! -L "$HOME/.config/$name" ]; then
        rm -rf "$HOME/.config/$name"
    fi
done
# Also handle any top-level config files (e.g. starship.toml)
for f in "$DOTFILES"/config/*; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if [ -e "$HOME/.config/$name" ] && [ ! -L "$HOME/.config/$name" ]; then
        rm -f "$HOME/.config/$name"
    fi
done
for f in .zshrc .bashrc .profile .gitconfig; do
    if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        rm -f "$HOME/$f"
    fi
done
# Clean up ~/.local/bin for local-bin stow package
for entry in "$DOTFILES"/local-bin/bin/*; do
    name=$(basename "$entry")
    if [ -e "$HOME/.local/bin/$name" ] && [ ! -L "$HOME/.local/bin/$name" ]; then
        rm -rf "$HOME/.local/bin/$name"
    fi
done

stow -R -d "$DOTFILES" -t "$HOME/.config" config 2>/dev/null || \
    stow -d "$DOTFILES" -t "$HOME/.config" config
stow -R -d "$DOTFILES" -t "$HOME"          home   2>/dev/null || \
    stow -d "$DOTFILES" -t "$HOME"          home
stow -R -d "$DOTFILES" -t "$HOME/.local"   local-bin 2>/dev/null || \
    stow -d "$DOTFILES" -t "$HOME/.local"   local-bin

# ── 3.5 Set login shell to zsh ──────────────────────────────────────────────
# The script may be run from bash. zsh is installed in step 2, so make it the
# login shell here — otherwise the stowed ~/.zshrc is never read.
if command -v zsh >/dev/null 2>&1; then
    current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
    if [[ "$current_shell" != "$(command -v zsh)" ]]; then
        log "Setting login shell to zsh..."
        sudo chsh -s "$(command -v zsh)" "$(id -un)"
    fi
fi

# ── 4. Clone Brain_Shell ────────────────────────────────────────────────────
if [ ! -d "$HOME/.local/src/Brain_Shell" ]; then
    log "Cloning Brain_Shell..."
    git clone https://github.com/Brainitech/Brain_Shell.git "$HOME/.local/src/Brain_Shell"
else
    log "Brain_Shell already cloned, pulling latest..."
    git -C "$HOME/.local/src/Brain_Shell" pull --ff-only 2>/dev/null || true
fi

# ── 5. Enable user systemd services ───────────────────────────────────────
# tmux is configured without TPM plugins (see config/tmux/tmux.conf);
# sessions are built by the deterministic tmux-sessions scripts instead.
log "Enabling user systemd services..."
systemctl --user daemon-reload
systemctl --user enable voxtype.service cliphist-wipe.service 2>/dev/null || \
    warn "Could not enable user services (finish the install manually)"

# ── 5.5 Optional system setup ──────────────────────────────────────────────
if [[ $SETUP_SYSTEM -eq 1 ]]; then
    setup_system
fi

# ── 6. OpenCode / secrets file ─────────────────────────────────────────────
if [ -f "$HOME/.opencode-secrets" ]; then
    log "OpenCode secrets file found (already configured)."
else
    warn "OpenCode secrets file not found; creating a template."
    cat > "$HOME/.opencode-secrets" <<'EOF'
# Fill in the values below, then reload the shell.
# export CONTEXT7_API_KEY="your-key"
# export BRAVE_API_KEY="your-key"
# export GOOGLE_CLOUD_PROJECT_ID="your-gcp-project"
# export GOOGLE_CLOUD_PROJECT="your-gcp-project"
EOF
    chmod 600 "$HOME/.opencode-secrets"
    echo "  Edit: ~/.opencode-secrets"
fi

# ── 6.5 Optional non-pacman tools ──────────────────────────────────────────
if [[ $INSTALL_TOOLS -eq 1 ]]; then
    install_tools
fi

# ── 7. Done — show remaining manual steps ──────────────────────────────────
echo ""
echo "=============================================="
echo " Dotfiles installed."
echo "=============================================="
echo ""

if [[ $SETUP_SYSTEM -eq 0 ]]; then
    echo "  System setup skipped (rerun with --system to automate):"
    echo "    greetd:      write /etc/greetd/config.toml and enable greetd"
    echo "    services:    sudo systemctl enable --now fstrim.timer docker firewalld libvirtd mullvad-daemon"
    echo "    groups:      sudo usermod -aG docker,libvirt $(id -un)   # then logout/login"
    echo "    firewall:    sudo firewall-cmd --set-default-zone=home"
    echo ""
fi

if [[ $INSTALL_TOOLS -eq 0 ]]; then
    echo "  Non-pacman tools skipped (rerun with --tools to automate):"
    echo "    1. uv:          curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "    2. rustup:      curl --proto '=https' -sSf https://sh.rustup.rs | sh"
    echo "    3. nvm:         curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
    echo "    4. opencode:    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path"
    echo "    5. tuxedo:      cargo install tuxedo"
    echo "    6. sqlit:       uv tool install --with psycopg2-binary sqlit-tui"
    echo ""
else
    echo "  Tool binaries live in ~/.local/bin, ~/.opencode/bin, and ~/.cargo/bin."
    echo "  Run 'exec zsh' (or re-login) to refresh PATH."
    echo ""
fi

echo "  After reboot:"
echo "    1. Open nvim — run: :lua vim.pack.update()"
echo "    2. Edit secrets: ~/.opencode-secrets"
echo "    3. Restore wallpapers to ~/Pictures/Wallpapers/"
echo "    4. Log into your accounts (browsers, Spotify, Signal, etc.)"
echo ""
