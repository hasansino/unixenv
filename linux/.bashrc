
# linux rc
# executed every time an interactive shell is started

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if type brew &>/dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    fi
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
        [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
fi

eval "$(zoxide init bash)"
eval "$(navi widget bash)"
