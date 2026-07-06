#!/usr/bin/env bash
# ~/.zshrc - Modern Zsh Configuration

# --- 1. Completions & Menu ---
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red} -- no matches found --%f'
zstyle ':completion:*' group-name '' # Group results by type

autoload -Uz add-zsh-hook

# Notify when commands take longer than 15 seconds
__cmd_start_time=0
__cmd_last=""

__notify_preexec() {
    __cmd_start_time=$SECONDS
    __cmd_last="$1"
}

__notify_precmd() {
    local elapsed=$((SECONDS - __cmd_start_time))
    if ((elapsed > 15)) && command -v notify-send >/dev/null 2>&1; then
        local short_cmd="${__cmd_last:0:80}"
        notify-send --urgency=low "Command finished (${elapsed}s)" "$short_cmd"
    fi
}

add-zsh-hook preexec __notify_preexec
add-zsh-hook precmd __notify_precmd

# Optimized compinit (only runs once a day or if changed)
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
  autoload -Uz compinit && compinit -C
else
  autoload -Uz compinit && compinit
fi

# --- 2. History & Prefix Search ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Robust Prefix Search (Try different escape sequences)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind for both "Normal" and "Application" cursor modes
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# Ctrl+Backspace: delete previous word (matches Kitty CSI-u sequence)
bindkey '^[[127;5u' backward-kill-word

# --- 3. Navigation Pro-Tips ---
# Global Aliases (type ... and it becomes ../..)
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc -l'
alias -g J='| jq'
alias -g c='clear'
alias -g cl='clear'
# Directory Stack (type "d" to see last 10 dirs, then "1-9" to jump)
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
alias d='dirs -v | head -n 10'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'

# Windows Navigation
alias win='cd /mnt/c/Users/josselin.peniguel'
hash -d win=/mnt/c/Users/josselin.peniguel

# --- 4. Aliases (Modern Tools) ---

# Tree command ignore pattern
TREE_IGNORE=".git|node_modules|__pycache__|.venv|venv|.tox|.nox|.mypy_cache|.pytest_cache|.ruff_cache|.hypothesis|.coverage|htmlcov|*.pyc|*.egg-info|.pdm-python|.Python|target|build|dist|.next|.nuxt|.svelte-kit|.output|.vercel|.serverless|.eslintcache|.cache|.pnpm-store|package-lock.json|yarn.lock|pnpm-lock.yaml|bun.lockb|.terraform|*.tfstate*|crash.log|crash.*.log|.terraform.lock.hcl|.gradle|.idea|.vscode|.vs|vendor|.bundle|.DS_Store|Thumbs.db|*.swp|*.swo|*~|.env|.env.*|*.log|coverage|.nyc_output|go.sum|npm-debug.log*"

# Dynamic tree aliases: t[N][d][s][p] where:
#   N = depth (2-5, omit for unlimited)
#   d = directories only
#   s = show size (-h -s --du)
#   p = show permissions (-p)
# Always shows hidden files (-a) with color (-C) and ignores TREE_IGNORE
__tree() {
  local name=$1; shift
  local -a a=()
  local rest=${name#t}
  if [[ $rest =~ ^([^0-9]*)([0-9])(.*)$ ]]; then
    a+=(-L "$match[2]")
    rest="${match[1]}${match[3]}"
  fi
  [[ $rest == *d* ]] && a+=(-d)
  [[ $rest == *s* ]] && a+=(-h -s --du)
  [[ $rest == *p* ]] && a+=(-p)
  command tree "${a[@]}" -a -C -I "$TREE_IGNORE" "$@"
}
for _depth in "" 2 3 4 5; do
  alias "t$_depth=__tree t$_depth"
  for _f1 in d s p; do
    alias "t${_depth}$_f1=__tree t${_depth}$_f1"
    for _f2 in d s p; do
      [[ $_f1 == $_f2 ]] && continue
      alias "t${_depth}$_f1$_f2=__tree t${_depth}$_f1$_f2"
      for _f3 in d s p; do
        [[ $_f2 == $_f3 || $_f1 == $_f3 ]] && continue
        alias "t${_depth}$_f1$_f2$_f3=__tree t${_depth}$_f1$_f2$_f3"
      done
    done
  done
done
# Number-at-end variants (e.g. tdsp2, ts3, etc.)
for _depth in 2 3 4 5; do
  for _f1 in d s p; do
    alias "t$_f1$_depth=__tree t$_f1$_depth"
    for _f2 in d s p; do
      [[ $_f1 == $_f2 ]] && continue
      alias "t$_f1$_f2$_depth=__tree t$_f1$_f2$_depth"
      for _f3 in d s p; do
        [[ $_f2 == $_f3 || $_f1 == $_f3 ]] && continue
        alias "t$_f1$_f2$_f3$_depth=__tree t$_f1$_f2$_f3$_depth"
      done
    done
  done
done
unset _depth _f1 _f2 _f3
	
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --grid --group-directories-first --header --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias tldrl='tldr -l | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

# Remove line numbers from code snippets (detects 5-6 char gutters)
# Automatically copies the result back to the clipboard
sn() {
  if [[ -t 0 && $# -eq 0 ]]; then
    # Read from clipboard, strip, copy back, and print
    powershell.exe -command "Get-Clipboard" | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]?//' | tee >(pbcopy)
  else
    # Read from pipe/file, strip, copy to clipboard, and print
    sed -E 's/^[[:space:]]*[0-9]+[[:space:]]?//' "$@" | tee >(pbcopy)
  fi
}

# Safe Aliases
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias df='df -h'

# Double-tap ESC to prepend sudo
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
alias lg='lazygit'
alias grep='grep --color=auto'
alias g='gemini'
alias oc='opencode'
_gq() { gemini --raw-output --accept-raw-output-risk --approval-mode plan -p "Answer concisely: $*" | uvx --with rich python3 -m rich.markdown - }
alias '??'='noglob _gq'

# --- 4a. Git Aliases ---
alias gst='git status'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'

# --- 4b. Docker Aliases ---
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcup='docker-compose up -d'
alias dcdwn='docker-compose down'
alias dclog='docker-compose logs -f'

# --- 4c. Infrastructure & Tools ---
alias tf='terraform'
alias clip="clip.exe"
alias vclip="powershell.exe -command 'Get-Clipboard'"

# WSL-Windows QoL Improvements
alias open='explorer.exe .'              # Open current folder in Windows Explorer
alias pbcopy='clip.exe'                  # macOS-style clipboard copy
alias pbpaste='powershell.exe -command "Get-Clipboard"' # macOS-style clipboard paste
alias powershell='powershell.exe'        # Run PowerShell directly
alias cmd='cmd.exe'                      # Run CMD directly

# Browse Windows from CLI
alias wdoc='cd /mnt/c/Users/josselin.peniguel/Documents'
alias wdl='cd /mnt/c/Users/josselin.peniguel/Downloads'
alias wdt='cd /mnt/c/Users/josselin.peniguel/Desktop'

# --- 4d. Yazi (File Manager) ---
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	# Force generic TERM and clear TERM_PROGRAM to skip hanging WezTerm/WSL handshake
	# YAZI_ID=$$ ensures a unique session ID
	YAZI_ID=$$ TERM=xterm TERM_PROGRAM="" EDITOR="nvim" command yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# --- 5. Environment Variables ---
export BAT_THEME="Catppuccin Mocha"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#cba6f7 \
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb \
  --color=info:#89b4fa,prompt:#89dceb,pointer:#89dceb \
  --color=marker:#a6e3a1,spinner:#a6e3a1,header:#a6e3a1"



# Source secrets from untracked file (API keys, tokens)
[ -f "$HOME/.opencode-secrets" ] && source "$HOME/.opencode-secrets"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- 6. FZF Integration ---
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Custom Shortcuts (FZF)
# Ctrl+F: Find Files (Global)
bindkey -r '^T'
bindkey '^F' fzf-file-widget
export FZF_CTRL_T_COMMAND='rg --files --hidden --glob "!.git/*" $HOME'
export FZF_CTRL_F_COMMAND="$FZF_CTRL_T_COMMAND"
export FZF_CTRL_F_OPTS="--preview 'batcat --color=always --style=numbers --line-range :500 {}' --height 60% --layout=reverse --border"

# Ctrl+G: Go to Directory (Global)
bindkey '^G' fzf-cd-widget
export FZF_ALT_C_COMMAND='find $HOME -mindepth 1 -maxdepth 5 -type d \( -name .git -o -name node_modules -o -name .cache \) -prune -o -type d -print 2>/dev/null'
export FZF_ALT_C_OPTS="--height 40% --layout=reverse --border --preview 'tree -C {} | head -200'"

export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Tmux session switcher (fzf): tms
#   - Lists all tmux sessions via fzf for selection
#   - Inside tmux: switches to selected session
#   - Outside tmux: attaches to selected session
#   - If no sessions exist, creates a new one
tms() {
  if ! tmux has-session 2>/dev/null; then
    echo "No tmux sessions found. Creating a new session..."
    tmux new-session
    return
  fi
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
    fzf --prompt="tmux > " --height=40% --layout=reverse --border)
  if [[ -n "$session" ]]; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$session"
    else
      tmux attach-session -t "$session"
    fi
  fi
}

# Create a new tmux session: tmn [name]
#   - If no name given, prompts for one
#   - If inside tmux, creates and switches to the new session
#   - If outside tmux, creates and attaches to the new session
tmn() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo -n "Session name: "
    read -r name
  fi
  if [[ -z "$name" ]]; then
    echo "No name given. Aborting."
    return 1
  fi
  if tmux has-session -t "$name" 2>/dev/null; then
    echo "Session '$name' already exists."
    return 1
  fi
  tmux new-session -d -s "$name"
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi
}

# --- 7. Hardware/App Integration ---
if [[ "$TERM" != "linux" ]]; then
  _wezterm_osc7() {
    printf "\033]7;file://%s%s\033\\" "${HOST:-$(hostname)}" "$PWD"
  }
  add-zsh-hook chpwd _wezterm_osc7
  _wezterm_osc7
fi

# --- 8. Plugins & Prompt ---
# Highlighting & Suggestions Configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244' # Grey color for suggestions

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Custom Highlighting Colors (Catppuccin Mocha)
ZSH_HIGHLIGHT_STYLES[command]='fg=#89b4fa,bold'    # Catppuccin Blue
ZSH_HIGHLIGHT_STYLES[alias]='fg=#cba6f7,bold'      # Catppuccin Mauve
ZSH_HIGHLIGHT_STYLES[path]='fg=#a6e3a1,underline'   # Catppuccin Green
ZSH_HIGHLIGHT_STYLES[function]='fg=#94e2d5,bold'    # Catppuccin Teal

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

source "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"

# Navi (Interactive Cheat Sheet)
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
  bindkey '^N' _navi_widget
fi

# direnv — per-project environment variables
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# --- 9. Python Venv Auto-activation ---
# Automatically activates a .venv/venv when entering its project tree,
# and deactivates when leaving it. Only affects venvs found by walking
# up from the current directory; manual activation is left untouched.
_auto_venv() {
    local venv_dir

    # Walk up from PWD to find the nearest .venv or venv
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            venv_dir="$dir/.venv"
            break
        elif [[ -f "$dir/venv/bin/activate" ]]; then
            venv_dir="$dir/venv"
            break
        fi
        dir="${dir:h}"
    done

    if [[ -n "$venv_dir" ]]; then
        # Found a venv
        if [[ -z "$VIRTUAL_ENV" ]]; then
            # No venv active — activate
            source "$venv_dir/bin/activate"
            export AUTO_VENV="$venv_dir"
        elif [[ "$VIRTUAL_ENV" != "$venv_dir" && "$VIRTUAL_ENV" == "$AUTO_VENV" ]]; then
            # Switched to a different project while auto-activated — switch venvs
            deactivate
            source "$venv_dir/bin/activate"
            export AUTO_VENV="$venv_dir"
        fi
        # If VIRTUAL_ENV is set but doesn't match AUTO_VENV (manual activation), leave it alone
    else
        # No venv found in tree — deactivate if we auto-activated one
        if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" == "$AUTO_VENV" ]]; then
            deactivate
            unset AUTO_VENV
        fi
    fi
}

alias dea='deactivate'

# Run on startup so the initial directory is handled
_auto_venv

# Run on every directory change
add-zsh-hook chpwd _auto_venv



# opencode
export PATH=/home/alpha/.opencode/bin:$PATH

# tmux session launchers
export PATH="$HOME/.local/bin/tmux-sessions:$PATH"


