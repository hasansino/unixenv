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

binaries() {
    # alias `goenv`
    ln -s "$(pwd)/bin/goenv-scp" /usr/local/bin/goenv-scp
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "OS: darwin"

    # check for homebrew
    if ! type brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. Please install Homebrew first."
    fi

    # .zprofile
    cat "$CLONE_DIR/macos/.zprofile" >> "$HOME/.zprofile"
    # .zshrc
    cat "$CLONE_DIR/generic/rc" >> "$HOME/.zshrc"
    cat "$CLONE_DIR/macos/zshrc" >> "$HOME/.zshrc"
    # .zsh_aliases
    cat "$CLONE_DIR/generic/aliases" >> "$HOME/.zsh_aliases"
    cat "$CLONE_DIR/macos/aliases" >> "$HOME/.zsh_aliases"

    # packages
    brew -q install wget curl watch nano htop
    brew -q install gotop zoxide fzf eza bat broot

    app_configs
    binaries

elif [[ -f /etc/debian_version ]]; then
    echo "OS: debian"

    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root to install packages"
    fi

    # .bash_profile
    cat "$CLONE_DIR/linux/.bash_profile" >> "$HOME/.bash_profile"
    # .bashrc
    cat "$CLONE_ DIR/generic/rc" >> "$HOME/.bashrc"
    cat "$CLONE_DIR/linux/.bashrc" >> "$HOME/.bashrc"
    # .bash_aliases
    cat "$CLONE_DIR/generic/aliases" >> "$HOME/.bash_aliases"
    cat "$CLONE_DIR/linux/.bash_aliases" >> "$HOME/.bash_aliases"

    # packages
    apt update
    apt install -q -y wget curl watch build-essential htop
    apt install -q -y zoxide fzf bat broot
    # packages - gotop
    wget https://github.com/xxxserxxx/gotop/releases/latest/download/gotop_v4.2.0_linux_amd64.deb
    dpkg -i gotop_v4.2.0_linux_amd64.deb || apt install -f -y
    rm -f gotop_v4.2.0_linux_amd64.deb
    # packages - nano 
    apt install -q -y libncurses-dev
    wget https://ftp.gnu.org/gnu/nano/nano-8.3.tar.gz
    tar -xf nano-8.3.tar.gz
    cd nano-8.3
    ./configure --prefix=/usr
    make
    make install
    rm -rf nano-8.3.tar.gz nano-8.3
    nano --version
    update-alternatives --install /usr/bin/editor editor /usr/bin/nano 100
    update-alternatives --set editor /usr/bin/nano
    # packages - eza
    apt install -q -y gpg
    mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    apt update
    apt install -q -y eza
    #packages - broot
    wget https://dystroy.org/broot/download/x86_64-linux/broot
    chmod +x broot
    mv broot /usr/local/bin/
    # ---

    app_configs
    binaries
else
    echo "Unsupported OS type."
    exit 1
fi
