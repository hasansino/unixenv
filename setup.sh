#!/bin/bash

set -e
set -x
set -o pipefail

file_missing() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    return 1
  else
    return 0
  fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "OS: darwin"

    # copy aliases
    if file_missing "$HOME/.zsh_aliases"; then
      touch "$HOME/.zsh_aliases"
    fi
    cat ./generic/aliases >> "$HOME/.zsh_aliases"
    cat ./macos/aliases >> "$HOME/.zsh_aliases"

    # update .zshrc
    if file_missing "$HOME/.zshrc"; then
      touch "$HOME/.zshrc"
    fi
    cat ./generic/rc >> "$HOME/.zshrc"
    cat ./macos/zshrc >> "$HOME/.zshrc"

    # update .zprofile
    if file_missing "$HOME/.zprofile"; then
      touch "$HOME/.zprofile"
    fi
    cat ./macos/zprofile >> "$HOME/.zprofile"

    # check for homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    # install packages
    brew install htop gotop thefuck broot bat exa

    # copy configurations
    cp ./generic/app_configs/htoprc "$HOME/.config/htop/htoprc"

elif [[ -f /etc/debian_version ]]; then
    echo "OS: debian"

    # copy aliases
    if file_missing "$HOME/.bash_aliases"; then
      touch "$HOME/.bash_aliases"
    fi
    cat ./generic/aliases >> "$HOME/.bash_aliases"
    cat ./linux/aliases >> "$HOME/.bash_aliases"

    # update .bashrc
    if file_missing "$HOME/.bashrc"; then
      touch "$HOME/.bashrc"
    fi
    cat ./generic/rc >> "$HOME/.bashrc"
    cat ./linux/bashrc >> "$HOME/.bashrc"

    # apt requires sudo
    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root"
      exit 1
    fi

    # install packages
    apt install htop thefuck broot bat exa
    curl -L https://github.com/xxxserxxx/gotop/releases/latest/download/gotop_v4.2.0_linux_amd64.deb -o gotop.deb
    dpkg -i gotop.deb

    # copy configurations
    cp ./generic/app_configs/htoprc "$HOME/.config/htop/htoprc"
else
    echo "Unsupported OS type."
    exit 1
fi