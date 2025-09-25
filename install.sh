#!/usr/bin/sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    sudo -v
fi

DOTFILES_DIR="$HOME/dotfiles"
ZED_CONFIG_DIR="$HOME/.var/app/dev.zed.Zed/config/zed" # Flatpak based installation

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles dir $DOTFILES_DIR not found"
    exit 1
fi

link_file() {
    local src="$1"
    local dest="$2"

	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(realpath "$src")" ]; then
	    echo "$dest already linked"
	    return
	fi

    if [ -e "$dest" ]; then
        echo "Backing up $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    echo "Linking $src -> $dest"
    ln -sf "$src" "$dest"
}

privileged_link_file() {
    local src="$1"
    local dest="$2"

	if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(realpath "$src")" ]; then
	    echo "$dest already linked"
	    return
	fi

    if [ -e "$dest" ]; then
        echo "Backing up $dest -> ${dest}.bak"
        sudo mv "$dest" "${dest}.bak"
    fi

    echo "Linking $src -> $dest"
    sudo ln -sf "$src" "$dest"
}

echo "==> Setting up bash"
link_file "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
link_file "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"

echo "==> Setting up nvim"
if [ ! -d   "$HOME/.config" ]; then
	mkdir -p "$HOME/.config"
fi

link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "==> Setting up Zed"
if [ ! -d  "$ZED_CONFIG_DIR" ]; then
	mkdir -p "$ZED_CONFIG_DIR"
fi

link_file "$DOTFILES_DIR/zed/settings.json" "$ZED_CONFIG_DIR/settings.json"
link_file "$DOTFILES_DIR/zed/keymap.json" "$ZED_CONFIG_DIR/keymap.json"

echo "==> Setting up keyd"
if [ ! -d "/etc/keyd" ]; then
    sudo mkdir -p "/etc/keyd"
fi

privileged_link_file "$DOTFILES_DIR/keyd/default.conf" "/etc/keyd/default.conf"

echo "==> Done"