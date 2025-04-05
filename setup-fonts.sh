#!/bin/bash

set -e
# set -x

# operate in temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Font URL
FONT_URL="https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip"
FONT_NAME="Cascadia Code"
ZIP_FILE="CascadiaCode.zip"

if ! command -v wget &> /dev/null; then
    echo "Error: wget is required, but not installed."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Error: unzip is required, but not installed."
    exit 1
fi

wget "$FONT_URL" -O "$ZIP_FILE"
unzip -q "$ZIP_FILE"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    find . -name "*.ttf" -exec cp {} "$FONT_DIR" \;
    fc-cache -fv
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONT_DIR"
    find . -name "*.ttf" -exec cp {} "$FONT_DIR" \;
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Successfully installed $FONT_NAME!"

rm -rf "$TMP_DIR"

echo "Finished."