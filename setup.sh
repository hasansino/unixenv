#!/bin/bash

set -e
set -x

# check if already installed
LOCK_FILE="$HOME/.unixenv.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "Already installed. To install again remove $LOCK_FILE."
    exit 1
fi
touch "$LOCK_FILE"

# clone remote repository
REPO_URL="https://github.com/hasansino/unixenv.git"
CLONE_DIR="$HOME/unixenv"
if [ -d "$CLONE_DIR" ]; then
  rm -rf "$CLONE_DIR"
fi
git clone "$REPO_URL" "$CLONE_DIR"

app_configs() {
    mkdir -p "$HOME/.config/htop"
    cp "$CLONE_DIR/generic/app_configs/htoprc" "$HOME/.config/htop/htoprc"
}

binaries() {
    sudo ln -s "$(pwd)/bin/goenv-scp" /usr/local/bin/goenv-scp
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "OS: darwin"

    # update .zprofile
    cat "$CLONE_DIR/macos/.zprofile" >> "$HOME/.zprofile"

    # update .zshrc
    cat "$CLONE_DIR/generic/rc" >> "$HOME/.zshrc"
    cat "$CLONE_DIR/macos/zshrc" >> "$HOME/.zshrc"

    # copy aliases
    cat "$CLONE_DIR/generic/aliases" >> "$HOME/.zsh_aliases"
    cat "$CLONE_DIR/macos/aliases" >> "$HOME/.zsh_aliases"

    # check for homebrew
    if ! type brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. Please install Homebrew first."
    else
        # install packages
        brew -q install htop gotop thefuck broot bat exa
    fi

    app_configs
    binaries

elif [[ -f /etc/debian_version ]]; then
    echo "OS: debian"

    cat "$CLONE_DIR/linux/.bash_profile" >> "$HOME/.bash_profile"

    # update .bashrc
    cat "$CLONE_ DIR/generic/rc" >> "$HOME/.bashrc"
    cat "$CLONE_DIR/linux/.bashrc" >> "$HOME/.bashrc"

    # copy aliases
    cat "$CLONE_DIR/generic/aliases" >> "$HOME/.bash_aliases"
    cat "$CLONE_DIR/linux/aliases" >> "$HOME/.bash_aliases"

    # apt requires sudo
    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root to install packages"
    else
      echo "Installing packages..."
      apt install -q -y htop broot bat exa
      curl -L https://github.com/xxxserxxx/gotop/releases/latest/download/gotop_v4.2.0_linux_amd64.deb -o gotop.deb
      dpkg -i gotop.deb || apt install -f -y
      rm -f gotop.deb
    fi

    app_configs
    binaries
else
    echo "Unsupported OS type."
    exit 1
fi
