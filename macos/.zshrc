
# darwin rc
# executed every time an interactive shell is started

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
fi

eval "$(zoxide init zsh)"
