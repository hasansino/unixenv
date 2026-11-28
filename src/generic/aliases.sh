# generic aliases
# read by zsh (darwin) and bash (linux): no array indexing, quote every variable, shared features only
# define functions as `function name {`: with `name() {`, an alias of the same name defined earlier breaks the file

# --- navigation ---

alias ..='cd ..'
alias c='clear'
alias xx='exit'
alias ll='eza --group-directories-first --show-symlinks --header -al -s name'
alias cnt='ls | wc -l'
alias path='echo "$PATH" | tr ":" "\n"'

# mc that leaves the shell in mc's last folder when you quit, like mc's own wrapper script but
# without its install path: mc -P writes that folder to a file, whichever way mc was installed
function mc {
    local last_dir_file last_dir
    last_dir_file=$(mktemp)
    command mc -P "$last_dir_file" "$@"
    last_dir=$(cat "$last_dir_file" 2> /dev/null)
    rm -f "$last_dir_file"
    if [ -n "$last_dir" ] && [ -d "$last_dir" ] && [ "$last_dir" != "$PWD" ]; then
        cd "$last_dir" || return
    fi
}

# --- utilities ---

alias bat='bat -p'
alias btm='btm -C ~/.config/btm.toml --autohide_time'
alias hf='hyperfine --warmup 3 --shell bash'
# dotfiles too; .gitignore rules still apply, and .git itself stays out
alias fd='fd --hidden --exclude .git'

# re-run setup from anywhere: setup.light where it installed its tool list (no Homebrew), setup otherwise
function unixenv {
    if [ -f "$HOME/.config/mise/conf.d/unixenv.toml" ]; then
        "$HOME/unixenv/setup.light" "$@"
    else
        "$HOME/unixenv/setup" "$@"
    fi
}

# a trick from ~/unixenv/src/share/tricks.yaml; ⏎ puts its command on the command line (zsh) or into history (bash: ↑)
function trick {
    local next_file next
    next_file=$(mktemp)
    TRICK_NEXT_FILE="$next_file" command trick
    next=$(cat "$next_file")
    rm -f "$next_file"
    if [ -z "$next" ]; then
        return 0
    fi
    if [ -n "$ZSH_VERSION" ]; then
        print -z -- "$next"
    else
        history -s -- "$next"
        echo "  press ↑ to get it"
    fi
}

# screensaver
function saver {
    if ! command -v pipes.sh > /dev/null 2>&1; then
        echo "saver: pipes.sh is not installed" >&2
        return 1
    fi
    pipes.sh "$@"
}

# --- remote ---

# ssh exits with 255 when the connection fails; then term-reset (src/bin) turns off the modes remote
# apps left on, which otherwise make every mouse move print escape codes.
function ssh {
    command ssh "$@"
    # not "status": zsh reserves that name for the exit code
    local exit_code=$?
    if [ "$exit_code" -eq 255 ] && command -v term-reset > /dev/null 2>&1; then
        term-reset
    fi
    return "$exit_code"
}

# --- git ---

alias gs='git status'
alias gb='git branch'
alias ga='git add .'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'

function grb {
    git rebase --autostash -i HEAD~"$1"
}

# --- docker ---

function dc {
    if [ "$1" = "ps" ]; then
        docker compose "$@" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Name}}"
    else
        docker compose "$@"
    fi
}

function dcr {
    if [ "$#" -eq 0 ]; then
        docker compose stop && docker compose up -d && docker compose logs -f
    else
        docker compose stop "$@" && docker compose up -d "$@" && docker compose logs -f "$@"
    fi
}

function dcrb {
    if [ "$#" -eq 0 ]; then
        docker compose stop && docker compose rm -vf && docker compose up -d && docker compose logs -f
    else
        docker compose stop "$@" && docker compose rm -vf "$@" && docker compose up -d "$@" && docker compose logs -f "$@"
    fi
}

function dnet {
    local container_name
    container_name="$(docker ps -a --format '{{.Names}}' | grep "$1")"
    docker run --rm -it --net "container:$container_name" nicolaka/netshoot iftop -bP
}

# --- kubernetes ---

function k {
    if [ -f "./.kubeconfig" ]; then
        KUBECONFIG="./.kubeconfig" kubectl "$@"
    else
        kubectl "$@"
    fi
}

function k9s {
    if [ -f "./.kubeconfig" ]; then
        KUBECONFIG="./.kubeconfig" command k9s "$@"
    else
        command k9s "$@"
    fi
}

# --- go ---

alias goclean='go clean -cache -modcache -i -r'
alias gotest='go test -race ./...'
alias gobench='go test -bench=.'

function goenv {
    source goenv-scp "$1" "$2"
}

function goinstall {
    GOPROXY=direct go install "$@"
}

# --- genai ---

alias agyd='agy --dangerously-skip-permissions'
alias clauded='nice -n 10 claude --dangerously-skip-permissions'
alias coded='codex --dangerously-bypass-approvals-and-sandbox'
alias crushed='crush -y'

# --- extra ---

# runs gogh's installer straight from its website
alias gogh='bash -c "$(curl -fsSL https://gogh.website/gogh)"'
alias gogek='docker run --rm -it -p 8888:8080 ghcr.io/hasansino/gogek:latest'
