#!/bin/bash

# Prerequisites: git & homebrew
#
# Install homebrew:
# `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
# + sudo apt-get install build-essential procps curl file

set -e
# set -x

# do not allow root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: running from root is not allowed."
    exit 1
fi

# check for homebrew
if ! type brew >/dev/null 2>&1; then
    echo "Error: homebrew is required, but not installed."
    exit 1
fi

# check for git
if ! type git > /dev/null 2>&1; then
    echo "Error: git is required, but not installed."
    exit 1
fi

# clone or update remote repository
REPO_URL="https://github.com/hasansino/unixenv.git"
CLONE_DIR="$HOME/unixenv"
if [ -d "$CLONE_DIR" ]; then
    echo "Updating git repo..."
    git -C "$CLONE_DIR" pull origin master
else
    echo "Cloning git repo..."
    git clone "$REPO_URL" "$CLONE_DIR"
fi

# operate in temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

update_file() {
    local header="#_____UNIXENV_CONFIG_START____"
    local footer="#_____UNIXENV_CONFIG_END______"
    local source="$1"
    local target="$2"

    local escaped_header=$(printf '%s\n' "$header" | sed 's/[][\\/.^$*]/\\&/g')
    local escaped_footer=$(printf '%s\n' "$footer" | sed 's/[][\\/.^$*]/\\&/g')

    if [ ! -f "$target" ]; then
        printf "%s\n%s\n%s\n" "$header" "$source" "$footer" > "$target"
    elif grep -q "$header" "$target" && grep -q "$footer" "$target"; then
        TMP_FILE=$(mktemp)
        printf "%s\n%s\n%s\n" "$header" "$source" "$footer" > "$TMP_FILE" #Removed extra newlines
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/$escaped_header/,/$escaped_footer/d" "$target"
        elif [[ "$OSTYPE" == "linux-gnu" ]]; then
            sed -i "/$escaped_header/,/$escaped_footer/d" "$target"
        else
            echo "Unsupported operating system."
            return 1
        fi

        cat "$TMP_FILE" >> "$target"
        rm "$TMP_FILE"
    else
        printf "%s\n%s\n%s\n" "$header" "$source" "$footer" >> "$target"
    fi
}

packages() {
    brew install ca-certificates
    brew install wget nano htop watch unzip
    brew install gotop bottom zoxide fzf eza bat broot navi dust
}

configs() {
    # nano
    cp "$CLONE_DIR/generic/.config/.nanorc" "$HOME/.nanorc"
    # git
    cp "$CLONE_DIR/generic/.config/.gitconfig" "$HOME/.gitconfig"
    cp "$CLONE_DIR/generic/.config/.gitignore" "$HOME/.gitignore"
    # btm
    cp "$CLONE_DIR/generic/.config/btm.toml" "$HOME/.config/btm.toml"
    # htop
    mkdir -p "$HOME/.config/htop"
    cp "$CLONE_DIR/generic/.config/htoprc" "$HOME/.config/htop/htoprc"
    # eza
    mkdir -p "$HOME/.config/eza"
    cp "$CLONE_DIR/generic/.config/eza.theme.yml" "$HOME/.config/eza/theme.yml"
}

scripts() {
    # alias `goenv`
    if [ ! -L "$HOME/.local/bin/goenv-scp" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -s "$CLONE_DIR/bin/goenv-scp" "$HOME/.local/bin/goenv-scp"
    fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "OS: darwin"

    # .zprofile
    update_file "$(cat "$CLONE_DIR/macos/.zprofile")" "$HOME/.zprofile"
    # .zshrc
    update_file "$(cat "$CLONE_DIR/macos/.zshrc" "$CLONE_DIR/generic/rc")" "$HOME/.zshrc"
    # .zsh_aliases
    update_file "$(cat "$CLONE_DIR/macos/.zsh_aliases" "$CLONE_DIR/generic/aliases")" "$HOME/.zsh_aliases"   

    packages
    configs
    scripts

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "OS: linux"    

    # .bash_profile
    update_file "$(cat "$CLONE_DIR/linux/.bash_profile")" "$HOME/.bash_profile"
    # .bashrc 
    update_file "$(cat "$CLONE_DIR/linux/.bashrc" "$CLONE_DIR/generic/rc")" "$HOME/.bashrc"
    # .bash_aliases
    update_file "$(cat "$CLONE_DIR/linux/.bash_aliases" "$CLONE_DIR/generic/aliases")" "$HOME/.bash_aliases"

    packages
    configs
    scripts
else
    echo "Unsupported OS type."
    exit 1
fi

echo "Finished."
