
# darwin rc
# executed every time an interactive shell is started

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

eval "$(zoxide init zsh)"

source $HOME/.config/broot/launcher/bash/br