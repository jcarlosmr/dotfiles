# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

unsetopt nomatch

source "${ZINIT_HOME}/zinit.zsh"

# Dependecies verification
REQS=(fzf tmux eza bat zoxide vim stow)

check_dependencies() {
    local missing_pkgs=()
    
    for pkg in "${REQS[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "📦 Paquetes faltantes detectados: ${missing_pkgs[*]}"
        echo "Solicitando privilegios para instalar vía DNF..."
        sudo dnf install -y "${missing_pkgs[@]}"
    fi
}

# Excecute dependecies verification
check_dependencies


# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::ansible
zinit snippet OMZP::podman
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::golang
zinit snippet OMZP::npm
zinit snippet OMZP::sudo
zinit snippet OMZP::ssh
zinit snippet OMZP::tailscale
zinit snippet OMZP::vscode
zinit snippet OMZP::dnf
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybinding
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[H'    beginning-of-line   # Tecla Home
bindkey '^[[F'    end-of-line         # Tecla End

# -------------------------------------------
# Edit Command Buffer
# -------------------------------------------
# Open the current command in your $EDITOR (e.g., neovim)
# Press Ctrl+X followed by Ctrl+E to trigger
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# -------------------------------------------
# Hotkey Insertions - Text Snippets
# -------------------------------------------
# Insert git commit template (Ctrl+X, G, C)
# \C-b moves cursor back one position
bindkey -s '^Xgc' 'git commit -m ""\C-b'

# More git bindinds:
bindkey -s '^Xgp' 'git push origin '
bindkey -s '^Xgs' 'git status\n'
bindkey -s '^Xgl' 'git log --oneline -n 10\n'

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
setopt complete_aliases
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --color=always $realpath'

# Funcion zmv usa patrones para mover archivos/directorio, supuestamente es mas potente
# 1. Cambiar todas las extensiones .JPG → .jpg (más común en minúsculas)
# zmv '(*).JPG' '$1.jpg'
# 2. Quitar el prefijo "IMG_" de todas las fotos
# zmv 'IMG_(#q.)' '$1'
# 3. Poner fecha al principio del nombre
# zmv '(*)(.jpg)' '${(l:19::0:)${(P)1}} $2'
# 4. Reemplazar espacios por guiones bajos (muy usado)
# zmv '* *' '${(C)1// /_}'
# 5. Modo interactivo (pregunta antes de cada cambio)
# zmv -i '(foto*).jpg' 'Vacaciones-$1.jpg'
# 6. Solo previsualizar (dry-run) sin hacer nada
# zmv -n '(*).JPG' '$1.jpg'
autoload -Uz zmv

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ---------------------
# Custom Configurations
# ---------------------
# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# --------------
# Custom exports
# --------------
export TERM=xterm-256color
export EDITOR=vim
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/usr/local/go/bin

# Golang
export PATH=$PATH:~/go/bin
export GOPATH=~/go

export VAGRANT_DEFAULT_PROVIDER=virtualbox

export PATH=~/.console-ninja/.bin:$PATH

. "$HOME/.atuin/bin/env"

# --------------
# Custom aliases
# --------------
alias ls='eza --icons'
alias ll='eza -al --icons'
alias cat='bat'
alias pcat='bat -p'

compdef ll=eza
compdef ls=eza

alias yt-dlp-video='yt-dlp -t mkv -f bestvideo+bestaudio'
alias yt-dlp-list="yt-dlp -t mkv -f bestvideo+bestaudio -o \"\%(playlist)s/\%(playlist_index)s - \%(title)s.%(ext)s\""
alias dnf-jv='sudo dnf --disablerepo=mullvad-stable,protonvpn-fedora-stable'
alias sshlocalconfig='vim ~/.ssh/config'

# Pipe to jq
alias -g J='| jq'

# Redirect stderr to /dev/null
alias -g NE='2>/dev/null'

# Redirect stdout to /dev/null
alias -g NO='>/dev/null'

# Redirect both stdout and stderr to /dev/null
alias -g NUL='>/dev/null 2>&1'

# Redirect output with tee /dev/null
alias -g TEE='| tee'

# Redirect output with tee /dev/null
alias -g TEEA='| tee -a'
