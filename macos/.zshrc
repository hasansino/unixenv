
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

eval "$(zoxide init zsh)"
eval "$(navi widget zsh)"
eval "$(gh completion -s zsh)"
eval "$(starship init zsh)"
