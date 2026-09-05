# Dotfiles — Arch + Hyprland + tmux + Neovim

Full desktop configuration for an **Arch Linux** system running **Hyprland** (Wayland compositor), **Kitty** terminal emulator, **tmux** multiplexer, and **Neovim** editor — all unified under a **Catppuccin Mocha** color theme.

## Hardware Context

- **Laptop**: Laptop (Intel CPU, 16GB RAM, NVIDIA GPU)
- **Docked**: Dual external monitors (2560×1440 @ 120Hz)
- **GPU**: Intel integrated + NVIDIA Optimus (via envycontrol)
- **Login**: greetd + tuigreet → Hyprland

## Prerequisites

The `install.sh` script assumes:
- Arch Linux base is installed (partitioning, bootloader, base packages)
- User `alpha` exists with sudo access
- An active internet connection
- Wallpapers are restored separately (not in this repo)

## Quick Start

```bash
git clone git@github.com:AlphaAlchiba/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Post-Install Checklist

After `install.sh` completes:

### Sudo commands (run these now)

```bash
sudo systemctl enable --now docker firewalld
sudo usermod -aG docker $USER
sudo firewall-cmd --set-default-zone=home
```

After `usermod`, log out and back in for the docker group to take effect.

### After reboot

1. **Open nvim** — run `:lua vim.pack.update()` to install all plugins (pinned by `nvim-pack-lock.json`)
2. **Install OpenCode** — `curl -fsSL https://opencode.ai/install.sh | sh`
3. **Set up OpenCode API key** — `echo 'export CONTEXT7_API_KEY="your-key"' > ~/.opencode-secrets && chmod 600 ~/.opencode-secrets`
4. **Restore wallpapers** — copy your collection to `~/wallpapers/`
5. **Log into accounts** — browsers, Spotify, Signal, Mullvad VPN
6. **Reload tmux** — run `tmux source-file ~/.config/tmux/tmux.conf` or `prefix+r`, then `prefix+I` to install plugins

## Key Bindings Reference

### Hyprland (Super = Windows/Command key)

| Keys | Action |
|---|---|
| `Super + Return` | Open terminal (kitty) |
| `Super + B` | Open browser (zen-browser) |
| `Super + E` | Open file manager (dolphin) |
| `Super + R` | Open app launcher (hyprlauncher) |
| `Super + C` | Close focused window |
| `Super + Q` | Quit Hyprland (if hyprshutdown is available) |
| `Super + F` | Toggle fullscreen |
| `Super + X` | Toggle window float |
| `Super + V` | Open clipboard (Brain_Shell) |
| `Super + S` | Screenshot region → satty annotation |
| `Super + Shift + S` | Screenshot window → satty annotation |
| `Super + P` | Color picker (hyprpicker) |
| `Super + H/J/K/L` | Move focus (vim-style) |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Alt + H/J/K/L` | Resize window |
| `Super + 0-9` | Switch workspace |
| `Super + Shift + 0-9` | Move window to workspace |
| `Super + M` | Toggle Spotify special workspace |
| `Super + O` | Toggle Obsidian special workspace |
| `Super + I` | Toggle Signal special workspace |
| `Super + D` | Dashboard home (Brain_Shell) |
| `Super + Space` | Dashboard launcher (Brain_Shell) |
| `Super + A` | Audio output toggle (Brain_Shell) |
| `Super + N` | Notifications popup (Brain_Shell) |
| `Super + W` | Wallpaper picker (Brain_Shell) |
| `Super + Esc` | Power menu (Brain_Shell) |
| `Super + Period` | Focus mode (Brain_Shell) |
| `Alt + F9` | Screen recording (Brain_Shell) |

### Tmux (prefix = `Alt + Space`)

| Keys | Action |
|---|---|
| `Alt+Space` | Prefix key |
| `prefix + r` | Reload tmux config |
| `prefix + \|` | Split pane horizontally |
| `prefix + -` | Split pane vertically |
| `prefix + \` | Split pane horizontally (full width) |
| `prefix + _` | Split pane vertically (full height) |
| `prefix + Enter` | New window |
| `prefix + w` | Choose window |
| `prefix + ,` | Rename window |
| `prefix + C` | Kill window |
| `prefix + c` / `prefix + x` | Kill pane |
| `prefix + z` | Zoom pane |
| `prefix + H/J/K/L` | Resize pane (3px) |
| `prefix + g` | Open lazygit popup |
| `prefix + s` | Fzf session switcher |
| `prefix + N` | New session prompt |
| `prefix + y` | Open yazi file manager |
| `prefix + P` | Edit .zshrc in nvim |
| `prefix + t` | New zsh popup |
| `Ctrl + h/j/k/l` | Navigate panes (vim-style, passes through to vim when detected) |
| `Ctrl + \` | Previous pane |
| `Ctrl + Backspace` | Delete previous word (passthrough to app) |
| `Shift + Enter` | Passthrough to app |

### Neovim (leader = `Space`)

| Keys | Action |
|---|---|
| `<Space>sh` | Search help |
| `<Space>sf` | Find files |
| `<Space>sg` | Live grep |
| `<Space>sw` | Search current word |
| `<Space>sd` | Search diagnostics |
| `<Space>sr` | Resume last search |
| `<Space>ss` | Select telescope picker |
| `<Space>sn` | Search nvim config files |
| `<Space><Space>` | Find buffers |
| `<Space>/` | Fuzzily search in current buffer |
| `<Space>e` | Open mini.files |
| `<Space>gg` | Git status (Neogit) |
| `<Space>gd` | Git diff (Diffview) |
| `<Space>u` | Toggle undotree |
| `<Space>q` | Open diagnostic quickfix list |
| `<Space>f` | Format buffer |
| `<Space>db` | Database UI (Dadbod) |
| `Ctrl + h/j/k/l` | Navigate splits / tmux panes |
| `grr` | LSP references |
| `grn` | LSP rename |
| `gra` | LSP code action |
| `grd` | LSP go to definition |
| `gO` | LSP document symbols |
| `]c` / `[c` | Next/previous git hunk |
| `<F5>` | Debug continue |
| `<Space>b` | Toggle breakpoint |
| `<Space>lp` | Log variable under cursor (chainsaw) |
| `<Space>lo` | Log object under cursor (chainsaw) |
| `<Space>lt` | Log type under cursor (chainsaw) |
| `<Space>lr` | Remove all chainsaw log statements |
| `<Space>lc` | Clear console (chainsaw) |
| `Tab` / `S-Tab` | Jump out of / back into brackets, quotes (insert mode, tabout) |

## Architecture Notes

### CSI-u Key Passthrough Chain

```
Kitty → tmux → application (zsh/nvim)
```

- `Ctrl+Backspace` and `Shift+Enter` are sent from Kitty as CSI-u escape sequences
- tmux forwards them via `send-keys` (they pass through to the focused application)
- zsh binds `Ctrl+Backspace` to `backward-kill-word`
- This three-layer chain must be kept in sync — each layer has explicit config

### Tmux + vim-tpipeline Status Bar

The tmux status bar uses a workaround for showing both session info and nvim's statusline:
- `window_start_flag` prepends the session name on the first window (no `status-left` needed)
- `vim-tpipeline` embeds nvim's lualine status into tmux's dynamically via named pipes
- `tpipeline_preservebg = 1` prevents tpipeline from overriding lualine's custom background
- Both tmux and lualine use `bg=#24243a` for visual continuity
- Pane borders use `fg=colour234` to blend into the background

### vim-tmux-navigator Integration

Three layers must stay synchronized:
1. **Tmux**: `Ctrl+h/j/k/l` navigate panes globally, with vim detection (`is_vim` shell var)
2. **Neovim**: `vim-tmux-navigator` plugin provides the same binds for nvim splits
3. When vim is detected in the focused pane, tmux passes the key through instead of navigating

### Session Persistence

- **tmux-resurrect** + **tmux-continuum** saves/restores tmux sessions across reboots
- **persistence.nvim** saves/restores nvim sessions per-project
- **nvim-pack-lock.json** pins all plugin versions for reproducible restoration

### Startup Chain

```
greetd → tuigreet (login) → Hyprland
  ├── hypridle       (idle daemon, lock/suspend)
  ├── hyprpolkitagent (polkit authentication)
  ├── cliphist        (clipboard history, text + image)
  ├── awww-daemon     (wallpaper daemon)
  └── Brain_Shell     (Quickshell overlay — dashboard, popups, panels)
       ├── Dashboard home, stats, kanban, launcher, config
       ├── Popups: power menu, notifications, clipboard, wallpaper picker
       ├── Network: wifi, bluetooth, VPN
       └── Audio: output, input, mixer
```

## Known Issues

- **NVIDIA driver** (`nvidia-open-dkms`): Requires envycontrol to switch between integrated and hybrid mode. The driver may need manual setup. If you don't need the dGPU, remove the package (it rebuilds on every kernel update).
- **Dual hypridle configs**: Two copies exist — one in `~/.config/hypr/hypridle.conf` (stale) and one in Brain_Shell's source tree. The autostart uses the Brain_Shell copy. The repo only tracks the Brain_Shell version.
- **`.gitconfig`**: Global git config is managed through dotfiles (stowed). Changes should be made in `~/dotfiles/home/.gitconfig`, not `~/.gitconfig` directly.

## Color Palette Reference

Catppuccin Mocha hex values for configuring new tools:

| Name | Hex | Usage |
|---|---|---|
| Rosewater | `#f5e0dc` | Cursor, selection |
| Mauve | `#cba6f7` | Git branch, aliases, rainbow delimiter |
| Red | `#f38ba8` | Errors, git status, delete signs |
| Peach | `#fab387` | Rust icon, sudo, AWS, builtin functions |
| Yellow | `#f9e2af` | Jobs, command duration, type defs |
| Green | `#a6e3a1` | Success, Node.js, function defs |
| Teal | `#94e2d5` | Strings, zsh functions, rainbow delimiter |
| Sky | `#89dceb` | Python, Go icons |
| Blue | `#89b4fa` | Directory, GCP, Docker, commands |
| Lavender | `#b4befe` | Active border |
| Text | `#cdd6f4` | Foreground, FZF text |
| Surface0 | `#313244` | FZF selection background |
| Surface1 | `#45475a` | Indent guides |
| Surface2 | `#585b70` | Ibl scope highlight |
| Overlay0 | `#6c7086` | Inactive border |
| Base | `#1e1e2e` | Background, Kitty background |
| Mantle | `#181825` | Session name bg, Kitty inactive tab |
| Crust | `#11111b` | Kitty tab bar bg |
