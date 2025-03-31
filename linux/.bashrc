
# linux rc
# executed every time an interactive shell is started

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

eval "$(zoxide init bash)"
