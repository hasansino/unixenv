# darwin rc
# executed every time an interactive shell is started

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

if [ -x /opt/homebrew/bin/brew ]; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
    typeset -U fpath
    autoload -Uz compinit
    compinit -i
fi

# --no-cmd keeps z and zi from src/generic/rc
eval "$(zoxide init zsh --no-cmd)"
eval "$(navi widget zsh)"
eval "$(gh completion -s zsh)"
eval "$(starship init zsh)"
