# Dotfiles Workflow Guide

## Your Stack at a Glance

| Layer | Tool | Role |
|---|---|---|
| Display | Hyprland 0.55.4 | Wayland compositor, window management |
| Terminal | Kitty 0.47.1 | GPU-accelerated terminal emulator |
| Multiplexer | tmux 3.6b | Session management, panes, persistence |
| Shell | zsh 5.9.1 | Starship prompt, fzf, auto-suggestions, direnv |
| Editor | Neovim | Kickstart-based, LSP, linting, formatting |
| Overlay | Brain_Shell (Quickshell) | Dashboards, popups, audio, network, clipboard |

**Autostart chain**: greetd → Hyprland → awww-daemon, hypridle, hyprpolkitagent, cliphist, Brain_Shell

**Color theme**: Catppuccin Mocha throughout (hex reference in README.md)

---

## How Dotfiles Work

### The Source of Truth

```
~/dotfiles/                          ← git repo (github.com:AlphaAlchiba/arch-dotfiles)
├── config/                  ← stowed to ~/.config/
│   ├── tmux/tmux.conf
│   ├── hypr/hyprland.lua + modules/
│   ├── kitty/kitty.conf
│   ├── nvim/init.lua + lua/
│   └── ... (starship, fastfetch, gtk, lazygit, opencode, etc.)
├── home/                            ← stowed to ~/
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .bashrc
│   └── .profile
├── local-bin/bin/            ← stowed to ~/.local/bin/
│   ├── env
│   ├── env.fish
│   ├── hypr-layout-notify    ← keyboard layout change notifications
│   └── tmux-sessions/
├── packages/
│   ├── official.txt                 ← pacman -Qqen
│   └── aur.txt                      ← pacman -Qqem
├── install.sh                       ← fresh-install bootstrap
├── justfile                         ← management recipes (just install/update/doctor/...)
├── README.md                        ← restore guide + keybind reference
└── WORKFLOW.md                      ← this file
```

### Stow Link Structure

GNU Stow creates symlinks from the repo to your home directory. Whole directories are linked at the top level, so adding files to an already-stowed directory makes them live instantly — no re-stow needed.

| Dotfiles path | Live path | Type |
|---|---|---|
| `~/dotfiles/config/tmux/` | `~/.config/tmux/` | Whole directory symlink |
| `~/dotfiles/config/hypr/` | `~/.config/hypr/` | Whole directory symlink |
| `~/dotfiles/config/nvim/` | `~/.config/nvim/` | Whole directory symlink |
| `~/dotfiles/config/kitty/` | `~/.config/kitty/` | Whole directory symlink |
| `~/dotfiles/home/.zshrc` | `~/.zshrc` | Single file symlink |
| `~/dotfiles/home/.gitconfig` | `~/.gitconfig` | Single file symlink |
| `~/dotfiles/local-bin/bin/` | `~/.local/bin/` | Whole directory symlink |

---

## Daily Workflow

### Editing an Existing Config (99% of changes)

The file on disk is a symlink, so editing either path edits the dotfiles repo:

```bash
# 1. Edit the file (both paths lead to the same file)
nvim ~/.config/tmux/tmux.conf
# OR
nvim ~/dotfiles/config/tmux/tmux.conf

# 2. Test the change
tmux source-file ~/.config/tmux/tmux.conf

# 3. Commit and push
cd ~/dotfiles
git add -A
git commit -m "fix(tmux): reduce escape-time to 10ms"
git push
```

### Adding a New Config File to an Existing App

Create the file in the dotfiles repo — it appears live instantly because the parent directory is a symlink:

```bash
# 1. Create the file in the source of truth
nvim ~/dotfiles/config/tmux/new-plugin.conf

# 2. It's already live — the symlink propagates immediately
ls ~/.config/tmux/new-plugin.conf   # exists right away

# 3. Commit and push
cd ~/dotfiles
git add config/tmux/new-plugin.conf
git commit -m "feat(tmux): add new-plugin config"
git push
```

### Adding a New App to the Dotfiles

When you install a new tool and want its config tracked:

```bash
# 1. Create the config directory in dotfiles
mkdir -p ~/dotfiles/config/newapp/
cp -r ~/.config/newapp/* ~/dotfiles/config/newapp/

# 2. Remove the real directory (stow needs to replace it with a symlink)
rm -rf ~/.config/newapp

# 3. Re-stow to create the symlink
cd ~/dotfiles
stow -R -d . -t ~/.config config

# 4. Verify the symlink
ls -la ~/.config/newapp      # → ../dotfiles/config/newapp

# 5. Commit and push
git add config/newapp/
git commit -m "feat(config): add newapp config"
git push
```

### Installing a New Package

```bash
# 1. Install the package
sudo pacman -S new-package

# 2. Update the package list in dotfiles
pacman -Qqen | sort > ~/dotfiles/packages/official.txt

# 3. Commit and push
cd ~/dotfiles
git add packages/official.txt
git commit -m "feat(packages): add new-package"
git push
```

### Restoring After `git pull`

When you pull new top-level directories added by another machine:

```bash
cd ~/dotfiles && git pull
stow -R -d . -t ~/.config config
stow -R -d . -t ~ home
stow -R -d . -t ~/.local local-bin
```

### If a Symlink Breaks

```bash
# Fix: remove the broken target and re-stow
rm ~/.config/tmux                  # if it's a broken symlink
cd ~/dotfiles && stow -R -d . -t ~/.config config
```

---

## Git Workflow

### Commit Convention

From your `opencode/agents/build.md`:

```
type(scope): short summary
```

| Type | When to use |
|---|---|
| `feat` | New config, new package, new capability |
| `fix` | Bug fix, corrected setting |
| `docs` | README, workflow guide, comments |
| `refactor` | Reorganizing config files, no behavior change |
| `chore` | Package list updates, lock files |
| `style` | Formatting, color changes, visual tweaks |

**Examples from this repo:**
```
docs(dotfiles): add README with restore guide and keybind reference
feat(dotfiles): add install.sh bootstrap script
fix(tmux): reduce escape-time to 0
style(starship): align hex values to Catppuccin Mocha
```

### Before Every Commit / Push

1. **STOP** — review `git status` and `git diff --cached`
2. **One logical change per commit** — don't mix a tmux change with an nvim change in the same commit
3. **Push regularly** — GitHub is your backup. `git push`

### Branching Workflow

For anything beyond a quick config tweak:

```bash
git checkout -b feat/hypr-new-layout
# make changes, commit
git checkout main
git merge feat/hypr-new-layout
git push
```

Never commit directly to `main`/`master` for new work (per `instructions.md`).

---

## One Golden Rule

**Never replace a stow symlink with a real directory.** If you accidentally `rm -rf ~/.config/tmux` and recreate it as a real directory yourself, stow can no longer link into it.

**Fix**:
```bash
rm -rf ~/.config/tmux              # remove the real directory
cd ~/dotfiles && stow -R -d . -t ~/.config config   # re-link
```



## Quick Reference

### Key File Paths

| Path | What it is |
|---|---|
| `~/dotfiles/` | Source of truth — the git repo |
| `~/dotfiles/config/<app>/` | Per-app config (symlinked to `~/.config/<app>/`) |
| `~/dotfiles/home/.zshrc` | Shell config (symlinked to `~/.zshrc`) |
| `~/dotfiles/packages/official.txt` | Native package list |
| `~/dotfiles/packages/aur.txt` | AUR package list |
| `~/.opencode-secrets` | Centralized secrets: API keys + GCP project id (untracked, loaded by `.zshrc`) |
| `~/dotfiles/install.sh` | Fresh-install bootstrap script |
| `~/dotfiles/README.md` | Restore guide + keybind reference |
| `~/dotfiles/WORKFLOW.md` | This file |

### Common Operations

| Task | Command |
|---|---|
| Re-link after `git pull` | `just stow` (or `cd ~/dotfiles && stow -R -d . -t ~/.config config`) |
| Pull + re-link | `just update` |
| Verify system matches repo | `just doctor` |
| Validate configs | `just check` |
| Update package lists | `pacman -Qqen \| sort > ~/dotfiles/packages/official.txt` |
| Load new secrets into shell | `source ~/.opencode-secrets` |
| Verify symlink target | `ls -la ~/.config/tmux` (should show `-> ../dotfiles/config/tmux`) |
| Restore on new machine | `git clone https://github.com/AlphaAlchiba/arch-dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh --all` |

---

## Color Palette Reference

See the full Catppuccin Mocha hex table in [README.md](README.md).
