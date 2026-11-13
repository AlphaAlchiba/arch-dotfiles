# Dotfiles — Arch + Hyprland + tmux + Neovim

Full desktop configuration for an **Arch Linux** system running **Hyprland** (Wayland compositor), **Kitty** terminal emulator, **tmux** multiplexer, and **Neovim** editor — all unified under a **Catppuccin Mocha** color theme.

## Hardware Context

- **Laptop**: Intel + NVIDIA Optimus hybrid (16GB RAM)
- **Docked**: Dual 1440p monitors @ 120Hz
- **GPU**: Intel integrated + NVIDIA Optimus (via envycontrol)
- **Login**: greetd + tuigreet → Hyprland

## Monitors & Workspaces

`config/hypr/modules/monitors.lua` is the tracked, generic config. Machine-specific monitor rules (exact `desc:` strings, disabling a monitor, workspace pinning) go in `config/hypr/modules/monitors_local.lua`, which is gitignored. Copy `config/hypr/modules/monitors_local.lua.example` and see `config/hypr/README.md` for details.

Hyprland applies the first matching monitor rule, so the generic `output = ""` catch-all is loaded last; the local specific rules are loaded before it.

## Prerequisites

The `install.sh` script assumes:
- Arch Linux base is installed (partitioning, bootloader, base packages)
- User `alpha` exists with sudo access
- An active internet connection
- Wallpapers are restored separately (not in this repo)

For a step-by-step fresh install (partitioning, bootloader, AMD mini PC notes), see [INSTALL.md](INSTALL.md).

## Quick Start

```bash
git clone https://github.com/AlphaAlchiba/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Dotfiles Management (just)

The repo ships a `justfile` for day-to-day management — `just` is installed via `packages/official.txt`:

| Recipe | What it does |
|---|---|
| `just install` | Full bootstrap (same as `./install.sh`) |
| `just stow` | Re-link all stow packages |
| `just update` | `git pull --ff-only` + re-stow |
| `just packages` | Update all packages (`yay -Syu`) |
| `just check` | Validate configs (`hyprctl configerrors` + headless nvim load) |
| `just doctor` | Verify the system matches the repo: git state, symlinks, packages, services, tools |

`just doctor` is the one to run after any change or on a new machine — it exits non-zero and lists everything that drifted.

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
3. **Set up secrets** — create `~/.opencode-secrets` (chmod 600) with `CONTEXT7_API_KEY` and `BRAVE_API_KEY`; add `GOOGLE_CLOUD_PROJECT_ID` / `GOOGLE_CLOUD_PROJECT` there too for the Gemini aliases
4. **Restore wallpapers** — copy your collection to `~/wallpapers/`
5. **Log into accounts** — browsers, Spotify, Signal, Mullvad VPN
6. **Reload tmux** — run `tmux source-file ~/.config/tmux/tmux.conf` or `prefix + r`

## Key Bindings Reference

### Hyprland (Super = Windows/Command key)

| Keys | Action |
|---|---|
| `Super + Return` | Open terminal (kitty) |
| `Super + B` | Open browser (zen-browser) |
| `Super + E` | Open file manager (dolphin) |
| `Super + C` | Close focused window |
| `Super + F` | Toggle fullscreen |
| `Super + X` | Toggle window float |
| `Super + R` | Push-to-talk dictation (voxtype — hold to record) |
| `Super + H/J/K/L` | Move focus (vim-style) |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Alt + H/J/K/L` | Resize window |
| `Super + Shift + O` | Toggle tiling split direction |
| `Super + 0-9` | Switch workspace |
| `Super + Shift + 0-9` | Move window to workspace |
| `Super + Alt + 0-9` | Move window to workspace (stay on current) |
| `Super + Scroll` | Switch workspace |
| `Super + Drag` | Move (left button) / resize (right button) window with mouse |
| `Super + S` | Screenshot region → satty annotation |
| `Super + Shift + S` | Screenshot window → satty annotation |
| `Super + P` | Color picker (hyprpicker) |
| `Ctrl + Alt` | Cycle keyboard layout (US ↔ US International, with notification) |
| `Super + M` | Toggle Spotify special workspace |
| `Super + O` | Toggle Obsidian special workspace |
| `Super + I` | Toggle Signal special workspace |
| `Super + T` | Toggle Dank Calendar special workspace |
| `Super + U` | Toggle LocalSend special workspace |
| `XF86Audio*` / `XF86MonBrightness*` | Volume, mute, brightness, media keys (wpctl / playerctl / brightnessctl) |
| `Super + D` | Dashboard home (Brain_Shell) |
| `Super + Z` | Kanban dashboard (Brain_Shell) |
| `Super + Space` | Dashboard launcher (Brain_Shell) |
| `Super + Shift + C` | Dashboard config (Brain_Shell) |
| `Ctrl + Shift + Esc` | Dashboard stats (Brain_Shell) |
| `Super + Esc` | Power menu (Brain_Shell) |
| `Super + V` | Open clipboard (Brain_Shell) |
| `Super + N` | Notifications popup (Brain_Shell) |
| `Super + W` | Wallpaper picker (Brain_Shell) |
| `Super + A` | Audio output toggle (Brain_Shell) |
| `Super + Alt + I` | Audio input toggle (Brain_Shell) |
| `Super + Shift + M` | Audio mixer (Brain_Shell) |
| `Super + Alt + W` | WiFi toggle (Brain_Shell) |
| `Super + Alt + B` | Bluetooth toggle (Brain_Shell) |
| `Super + Alt + G` | VPN toggle (Brain_Shell) |
| `Super + Alt + H` | Hotspot toggle (Brain_Shell) |
| `Super + Period` | Focus mode (Brain_Shell) |
| `Alt + F9` | Screen recording (Brain_Shell) |

### Tmux (prefix = `Alt + Space`)

`Ctrl+b` is intentionally unbound; the prefix is `Alt + Space`. The tables below mirror `~/.config/tmux/tmux.conf` — keep them in sync when the config changes.

#### Prefix & Sessions

| Keys | Action |
|---|---|
| `Alt+Space` | Prefix key (prefix again sends `Alt+Space` to the app) |
| `prefix + r` | Reload tmux config (`source-file` + status message) |
| `prefix + d` | Detach session (default binding — session keeps running) |
| `prefix + s` | Fzf session switcher popup (excludes current session) |
| `prefix + S` | Choose session |
| `prefix + N` | New session popup (prompts for a name) |

#### Windows

| Keys | Action |
|---|---|
| `prefix + Enter` | New window (in pane's current directory) |
| `prefix + ,` | Rename window |
| `prefix + w` | Choose window |
| `prefix + C` | Kill window (no confirmation) |
| `prefix + n` / `prefix + p` | Next / previous window (repeatable) |
| `prefix + M-h` / `prefix + M-l` | Swap window with previous / next (repeatable, wraps around) |
| `prefix + .` | Move current window to a specific index (prompt) |

Windows are 1-based and renumber automatically when one is killed (`renumber-windows on`).

#### Panes

| Keys | Action |
|---|---|
| `prefix + \|` | Split left/right (in pane's current directory) |
| `prefix + -` | Split top/bottom (in pane's current directory) |
| `prefix + \` | Split left/right, pane spans full window height |
| `prefix + _` | Split top/bottom, pane spans full window width |
| `prefix + c` / `prefix + x` | Kill pane (no confirmation) |
| `prefix + z` | Zoom pane (toggle) |
| `prefix + H/J/K/L` | Resize pane by 3 cells (repeatable) |
| `prefix + m` / `prefix + M` | Move pane into window (prompt) / to the right into window |

#### Pane Navigation

| Keys | Action |
|---|---|
| `prefix + h/j/k/l` | Select pane (vim-style) |

#### Global Keys (no prefix)

| Keys | Action |
|---|---|
| `Ctrl + h/j/k/l` | Navigate panes (passes through to vim when detected) |
| `Ctrl + \` | Previous pane / split |
| `Ctrl + Backspace` | Delete previous word (passthrough to app) |
| `Shift + Enter` | Passthrough to app |

#### Popups

| Keys | Action |
|---|---|
| `prefix + g` | Open lazygit popup (90% size, pane's cwd) |
| `prefix + y` | Open yazi file manager (90% size, pane's cwd) |
| `prefix + t` | New zsh popup (75% size) |
| `prefix + P` | Edit `.zshrc` in nvim (80% size) |
| `prefix + N` | New session popup (prompts for a name) |
| `prefix + s` | Fzf session switcher |
| `prefix + S` | Choose session |

#### Copy Mode

| Keys | Action |
|---|---|
| `prefix + [` | Enter copy mode (vi keys); mouse scroll also enters it |
| `v` | Begin selection |
| `y` | Yank selection and exit copy mode |
| `q` | Exit copy mode |

#### Quitting / Leaving tmux

| Keys | Action |
|---|---|
| `prefix + c` / `prefix + x` | Kill current pane (no confirmation) |
| `prefix + C` | Kill current window (no confirmation) |
| `prefix + d` | Detach — leave tmux, keep the session running |
| `prefix + :` → `kill-session` | Kill the current session |
| `prefix + :` → `kill-server` | Shut down the whole tmux server |

Notes on the semantics:

- The destructive keys (`c`, `x`, `C`) fire **without a confirmation prompt** — the default `confirm-before` on `x` was deliberately replaced by an instant `kill-pane`. Most panes run nvim or opencode, so killing a pane kills that process too — exit the app cleanly first when you care about unsaved work.
- Killing the **last pane/window of a session** ends that session; tmux shuts down when the last session dies (`exit-empty` is on by default). You land back in the shell that launched the session.
- `prefix + d` detaches instead — the session keeps running and you can return with `tms` or the session scripts.
- Sessions started by the `tmux-sessions` scripts are just attached clients; ending them simply returns you to the launcher shell (the server stays alive if other sessions exist).

#### Tmux config notes

- **Prefix**: `Ctrl+b` is unbound and replaced with `Alt + Space` (with `Alt + Space` also bound as `send-prefix` for apps that use the chord). `escape-time 0` makes the Alt-prefix respond instantly instead of waiting for a potential ESC sequence.
- **Terminal**: `default-terminal tmux-256color` with `Tc` (truecolor) and `Km` (kitty keyboard protocol) terminal overrides; `extended-keys` + `extended-keys-format csi-u` and `allow-passthrough on` let Kitty's CSI-u sequences flow through to applications (see the CSI-u chain in Architecture Notes). `update-environment` carries `TERM`/`TERM_PROGRAM` through to panes.
- **Core behavior**: `mode-keys vi` (vim-style copy mode), `mouse on`, 50k scrollback, `focus-events on` (nvim refreshes on pane focus), 1-based window/pane indices, and `renumber-windows on` (killing a window renumbers the rest). `repeat-time 700` enables the repeatable `n`/`p` and `H/J/K/L` binds.
- **Status line**: `status-left`/`status-right` are emptied because vim-tpipeline injects nvim's lualine status through named pipes at runtime (see Architecture Notes). Session names are shown by the `window-status` format via `window_start_flag` — the window flagged as a session's start window gets a `#S` chip (`bg=#181825`/`fg=#FAB387`) prepended, so each session shows its name without needing `status-left`. The flag itself is applied to a session's start window outside the tracked config. Pane borders use `fg=colour234` (near-base) with heavy lines to blend into the background.
- **Global key handlers**: `Ctrl+h/j/k/l` and `Ctrl+\` navigate panes, but an `is_vim` check (process running in the focused pane) passes the key through to vim instead — synchronized with vim-tmux-navigator on the nvim side (see Architecture Notes). `Ctrl+Backspace` and `Shift+Enter` are forwarded as CSI-u passthroughs (`\e[127;5u` and `S-Enter`) so apps receive them.
- **Popups** use rounded borders and open `-E` (a command that exits with the popup) sized 75–90% of the window, most in the pane's current directory.
- **Session workflow — no TPM**: TPM/resurrect/continuum are disabled (commented out in the config). Sessions are instead deterministic scripts in `~/.local/bin/tmux-sessions/` (`tmux-template`, `ideavault`, `dotfiles`; the directory is on `PATH` via `.zshrc`): each is idempotent (`has-session` check), builds the full layout on first run — per-project windows with an nvim pane, a 30% opencode pane, and a 20% utility pane, root-level windows moved to indices 8–9, start window selected — then attaches. The `tms` (fzf session switcher), `tmn` (new session) and `tmk` (fzf session killer) zsh functions handle switching/creating/killing from the shell.

### Neovim (leader = `Space`)

#### Search & Files (Telescope)

| Keys | Action |
|---|---|
| `<Space>sh` | Search help |
| `<Space>sk` | Search keymaps |
| `<Space>sf` | Find files (incl. hidden) |
| `<Space>ss` | Select telescope picker |
| `<Space>sw` | Search current word |
| `<Space>sg` | Live grep |
| `<Space>s/` | Live grep in open files |
| `<Space>sd` | Search diagnostics |
| `<Space>sr` | Resume last search |
| `<Space>s.` | Recent files |
| `<Space>sc` | Search commands |
| `<Space>sn` | Search nvim config files |
| `<Space>sGc` | Git commits |
| `<Space>sGb` | Git branches |
| `<Space>sGs` | Git status |
| `<Space><Space>` | Find buffers |
| `<Space>/` | Fuzzily search in current buffer |
| `<Space>e` | Open mini.files |

#### Git

| Keys | Action |
|---|---|
| `<Space>gg` | Git status (Neogit) |
| `<Space>gd` | Git diff (staged vs working) |
| `<Space>gD` | Git diff against last commit |
| `<Space>gc` | Close diffview |
| `<Space>gh` | Git file history |
| `<Space>gH` | Git repo history |
| `<Space>gb` | Git blame (gitsigns) |
| `]c` / `[c` | Next/previous git hunk |

#### LSP

| Keys | Action |
|---|---|
| `gd` | Definition (jump) |
| `gD` | Declaration (jump) |
| `grr` | References |
| `gri` | Implementations |
| `grd` | Definition (fuzzy list) |
| `grt` | Type definition |
| `grD` | Declaration |
| `grn` | Rename |
| `gra` | Code action |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `gK` | Signature help |
| `K` | Hover |
| `<Space>th` | Toggle inlay hints |

#### Debug & Test

| Keys | Action |
|---|---|
| `<F5>` | Debug continue |
| `<Space>b` | Toggle breakpoint |
| `<Space>dd` | Debug continue/start |
| `<Space>ds` | Step over |
| `<Space>di` | Step into |
| `<Space>do` | Step out |
| `<Space>dt` | Toggle breakpoint |
| `<Space>dT` | Conditional breakpoint |
| `<Space>dR` | Restart session |
| `<Space>dX` | Terminate session |
| `<Space>du` | Toggle DAP UI |
| `<Space>tt` | Run nearest test |
| `<Space>tf` | Run test file |
| `<Space>tl` | Run last test |
| `<Space>ts` | Stop tests |
| `<Space>to` | Toggle test output |

#### Log (chainsaw)

| Keys | Action |
|---|---|
| `<Space>lp` | Log variable under cursor |
| `<Space>lo` | Log object under cursor |
| `<Space>lt` | Log type under cursor |
| `<Space>lr` | Remove all chainsaw log statements |
| `<Space>lc` | Clear console |

#### Other

| Keys | Action |
|---|---|
| `<Space>a` | Toggle aerial outline |
| `<Space>u` | Toggle undotree |
| `<Space>q` | Open diagnostic quickfix list |
| `<Space>xx` | Toggle diagnostics list (Trouble) |
| `<Space>xX` | Toggle buffer diagnostics (Trouble) |
| `<Space>xl` | Toggle location list (Trouble) |
| `<Space>xq` | Toggle quickfix list (Trouble) |
| `<Space>f` | Format buffer |
| `<Space>db` | Database UI (Dadbod) |
| `<Space>dq` | Database query |
| `Tab` / `S-Tab` | Jump out of / back into brackets, quotes (insert mode) |
| `Alt + h/j/k/l` | Move line (normal) / selection (visual) |
| `Ctrl + h/j/k/l` | Navigate splits / tmux panes |
| `Ctrl + \` | Previous split / tmux pane |
| `Ctrl + Backspace` | Delete previous word |
| `zi` | Toggle all folds open/closed |
| `zR` / `zM` | Open / close all folds |
| `<Esc>` | Clear search highlight |
| `<Esc><Esc>` | Exit terminal mode |

#### Neovim plugin notes

- **chainsaw** (`<Space>lp/lo/lt/lr/lc`): inserts log statements for the variable under the cursor (or visual selection). Every log line carries the 🪚 marker; `<Space>lr` removes all chainsaw log lines. The statusline shows a 🪚 counter while logs exist in the buffer. Other log types (assert, emoji, stacktrace, time, sound…) are available via `:Chainsaw <name>`.
- **tabout** (`Tab`/`S-Tab` in insert mode): jumps out of / back into brackets, quotes, etc. Falls back to normal Tab indentation when no pair is found. Snippet navigation via Tab keeps working — blink.cmp's fallback resolves to tabout.
- **dadbod SQL completion**: with an active vim-dadbod connection (`:DB` or DBUI), typing in SQL buffers completes table names, column names, and SQL keywords from the connected database's schema (`table.` triggers column completion). Requires a live connection; without one, no completions appear.
- **mini.move** (`Alt + h/j/k/l`): moves the current line in normal mode, the visual selection in visual mode.
- **mini.trailspace**: highlights trailing whitespace and strips it automatically on save.
- **trouble** (`<Space>xx/xX/xl/xq`): quickfix-style panel for LSP diagnostics, loclist, and quickfix. `<Space>xx` shows all workspace diagnostics, `<Space>xX` scopes to the current buffer.

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

- **tmux**: TPM/resurrect/continuum are disabled. Deterministic `tmux-sessions` scripts (`tmux-template`, `ideavault`, `dotfiles`) recreate the full session layout on demand — windows, panes, and the nvim/opencode processes they start. Re-running a script is idempotent: it attaches to the existing session or rebuilds it.
- **persistence.nvim** saves/restores nvim sessions per-project
- **nvim-pack-lock.json** pins all plugin versions for reproducible restoration

### Startup Chain

```
greetd → tuigreet (login) → Hyprland
  ├── hypridle       (idle daemon, lock/suspend)
  ├── hyprpolkitagent (polkit authentication)
  ├── cliphist        (clipboard history, text + image)
  ├── awww-daemon     (wallpaper daemon)
  ├── hypr-layout-notify (keyboard layout change notifications)
  └── Brain_Shell     (Quickshell overlay — dashboard, popups, panels)
       ├── Dashboard home, stats, kanban, launcher, config
       ├── Popups: power menu, notifications, clipboard, wallpaper picker
       ├── Network: wifi, bluetooth, VPN
       └── Audio: output, input, mixer
```

## Keyboard Layouts

Two layouts are configured: **US English** and **US International** (dead keys for accents). `Ctrl + Alt` (either side) cycles through them — handled by XKB (`grp:ctrl_alt_toggle`), so it works in every app and no modifier keys are consumed. Note that any `Ctrl + Alt` chord (e.g. `Ctrl + Alt + T` in an app) also cycles the layout.

`hypr-layout-notify` (in `local-bin/bin/`) listens to Hyprland's event socket and pops a 1-second notification with the new layout name on every change. It tracks all keyboards (XKB layout groups are per-device) and suppresses the initial startup event.

## Known Issues

- **NVIDIA driver** (`nvidia-open-dkms`): Requires envycontrol to switch between integrated and hybrid mode. The driver may need manual setup. If you don't need the dGPU, remove the package (it rebuilds on every kernel update).
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
