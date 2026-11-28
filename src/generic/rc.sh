# generic rc
# executed every time an interactive shell is started
# read by zsh (darwin) and bash (linux): no array indexing, quote every variable, shared features only
# define functions as `function name {`: with `name() {`, an alias of the same name defined earlier breaks the file

# --- off by default; uncomment to use ---

# export QT_SCALE_FACTOR=2.0
# goenv /opt 1.25.0
# go telemetry off

# --- editor ---

export EDITOR=nano
export VISUAL=nano

# setup creates nano's backupdir; recreate it if it was deleted, since nano will not start without it
if [ ! -d "$HOME/.local/state/nano/backups" ]; then
    mkdir -p "$HOME/.local/state/nano/backups"
fi

# --- environment ---

GPG_TTY=$(tty)
export GPG_TTY

# "The cure for boredom is curiosity. There is no cure for curiosity."
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# Build and test at most 6 Go packages at once, leaving cores for interactive work.
export GOFLAGS=-p=6

# --- tool settings ---

# bat reads its theme from here everywhere: the alias, fzf previews and mc
export BAT_THEME="OneHalfDark"

export EZA_CONFIG_DIR="$HOME/.config/eza"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=numbers {}'"
# fzf key bindings (zshrc/bashrc): Ctrl-T picks files, Alt-C folders, Ctrl-R history; bat cannot preview the last two
export FZF_ALT_C_OPTS="--preview 'ls {}'"
export FZF_CTRL_R_OPTS="--no-preview"
# file pickers list dotfiles too; .gitignore rules still apply, and .git itself stays out
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"

# --- navigation ---

# created by `broot --install`, which setup does not run
if [ -f "$HOME/.config/broot/launcher/bash/br" ]; then
    source "$HOME/.config/broot/launcher/bash/br"
fi

# zoxide is initialized with --no-cmd, so these replace its z and zi
function z {
    if [ "$#" -eq 0 ]; then
        cd "$(zoxide query -l | fzf --height 40% --reverse --preview 'ls {}')" || return
    else
        __zoxide_z "$@"
    fi
}

function zi {
    __zoxide_zi "$@"
}
