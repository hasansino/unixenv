# linux rc
# executed every time an interactive shell is started

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# here rather than in .bash_profile: terminals on linux desktops start non-login shells
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

if type brew &> /dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    fi
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
        [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
fi

# --no-cmd keeps z and zi from src/generic/rc
eval "$(zoxide init bash --no-cmd)"
eval "$(navi widget bash)"
eval "$(gh completion -s bash)"
eval "$(starship init bash)"
