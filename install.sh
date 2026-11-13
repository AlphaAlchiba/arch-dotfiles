#!/usr/bin/env bash
# =============================================================================
# Dotfiles Bootstrap Script
# =============================================================================
# Usage: cd ~/dotfiles && ./install.sh
#
# What this does:
#   1. Installs yay (AUR helper) if missing
#   2. Ranks mirrors (rate-mirrors) and enables paccache.timer
#   3. Installs all packages from packages/official.txt and packages/aur.txt
#   4. Stows config files into ~/.config with symlinks
#   5. Clones Brain_Shell to ~/.local/src/Brain_Shell
#   6. Enables user systemd services (voxtype, cliphist-wipe)
#   7. Checks for OpenCode API key in ~/.opencode-secrets
#
# Manual steps required after (see end of script):
#   - Enable and start system services (docker, firewalld)
#   - Open nvim to run vim.pack.update()
#   - Install OpenCode binary
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

# ── Pre-flight checks ──────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && err "Do not run as root. This script uses sudo where needed."
[[ -f "$DOTFILES/packages/official.txt" ]] || err "Missing $DOTFILES/packages/official.txt"
[[ -f "$DOTFILES/packages/aur.txt" ]]      || err "Missing $DOTFILES/packages/aur.txt"
command -v pacman >/dev/null 2>&1 || err "This script requires Arch Linux with pacman"

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

# ── 6. OpenCode API key ────────────────────────────────────────────────────
if [ -f "$HOME/.opencode-secrets" ]; then
    log "OpenCode secrets file found (already configured)."
else
    echo ""
    warn "OpenCode API key not found."
    warn "To set it up later:"
    echo "  echo 'export CONTEXT7_API_KEY=\"your-key-here\"' > ~/.opencode-secrets"
    echo "  chmod 600 ~/.opencode-secrets"
    echo ""
fi

# ── 7. Done — show manual steps ─────────────────────────────────────────────
echo ""
echo "=============================================="
echo " Dotfiles installed."
echo "=============================================="
echo ""
echo "  SUDO required:"
echo "    sudo systemctl enable --now docker firewalld"
echo "    sudo usermod -aG docker $USER   # then logout/login"
echo "    sudo firewall-cmd --set-default-zone=home"
echo ""
echo "  Non-pacman tools (install manually):"
echo "    1. uv:          curl -LsSf https://astral.sh/uv/install.sh | sh"
echo "    2. rustup:      curl --proto '=https' -sSf https://sh.rustup.rs | sh"
echo "    3. nvm:         curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
echo "    4. opencode:    curl -fsSL https://opencode.ai/install.sh | sh"
echo "    5. tuxedo:      cargo install tuxedo"
echo "    6. sqlit:       uv tool install --with psycopg2-binary sqlit-tui"
echo ""
echo "  After reboot:"
echo "    1. Open nvim — run: :lua vim.pack.update()"
echo "    2. Set up secrets: echo 'export CONTEXT7_API_KEY=your-key' > ~/.opencode-secrets"
echo "    3. Restore wallpapers to ~/wallpapers/"
echo "    4. Log into your accounts (browsers, Spotify, Signal, etc.)"
echo ""
