
# darwin profile
# executed once per login session

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# if [ -f "$HOME/.zshrc" ]; then
#     . "$HOME/.zshrc"
# fi

# show hidden files in Finder by default
defaults write com.apple.Finder AppleShowAllFiles true

if ! [ -f "/opt/.metadata_never_index" ]; then
    echo "Directory '/opt' is not excluded from spotlight indexing."
    echo "Creaete '/opt/.metadata_never_index' and run 'mdutil -i off /opt' to exclude it."
fi