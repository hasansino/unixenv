#!/bin/bash

# Prerequisites: homebrew & git
# Extra prerequisites for linux: build-essential procps curl file
#
# Install homebrew:
# `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

set -e
# set -x

# check for homebrew
if ! type brew >/dev/null 2>&1; then
    echo "Homebrew is required, but not installed."
    exit 1
fi

# check for git
if ! type git > /dev/null 2>&1; then
    echo "Git is required, but not installed."
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
    if [[ "$OSTYPE" == "darwin"* ]]; then
         
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        
    else
        echo "Unsupported operating system."
        return 1
    fi

    brew install ca-certificates
    brew install wget nano htop watch
    brew install gotop zoxide fzf eza bat broot
}

configs() {
    # nano
    mkdir -p "/tmp/.cache/nano"
    cp "$CLONE_DIR/generic/app_configs/.nanorc" "$HOME/.nanorc"
    # git
    cp "$CLONE_DIR/generic/app_configs/.gitconfig" "$HOME/.gitconfig"
    cp "$CLONE_DIR/generic/app_configs/.gitignore" "$HOME/.gitignore"
    # htop
    mkdir -p "$HOME/.config/htop"
    cp "$CLONE_DIR/generic/app_configs/htoprc" "$HOME/.config/htop/htoprc"
    # eza
    mkdir -p "$HOME/.config/eza"
    cp "$CLONE_DIR/generic/app_configs/eza.theme.yml" "$HOME/.config/eza/theme.yml"
}

scripts() {
    # alias `goenv`
    if [ ! -L "/usr/local/bin/goenv-scp" ]; then
        ln -s "$CLONE_DIR/bin/goenv-scp" /usr/local/bin/goenv-scp
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

    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root to install packages"
    fi

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

rm -rf "$TMP_DIR"

echo "Finished."