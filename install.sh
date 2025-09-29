#!/usr/bin/sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    sudo -v
fi

DOTFILES_DIR="$HOME/Dotfiles"
ZED_CONFIG_DIR="$HOME/.var/app/dev.zed.Zed/config/zed" # Flatpak based installation

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[ERROR] Dotfiles dir $DOTFILES_DIR not found"
    exit 1
fi

link_file() {
    local src="$1"
    local dest="$2"
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(realpath "$src")" ]; then
        echo "[INFO] $dest already linked"
        return
    fi
    if [ -e "$dest" ]; then
        echo "[INFO] Backing up $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    echo "[INFO] Linking $src -> $dest"
    ln -sf "$src" "$dest"
}

privileged_link_file() {
    local src="$1"
    local dest="$2"
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(realpath "$src")" ]; then
        echo "[INFO] $dest already linked"
        return
    fi
    if [ -e "$dest" ]; then
        echo "[INFO] Backing up $dest -> ${dest}.bak"
        sudo mv "$dest" "${dest}.bak"
    fi
    echo "[INFO] Linking $src -> $dest"
    sudo ln -sf "$src" "$dest"
}

echo "==> Setting up bash"
link_file "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
link_file "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"

echo "==> Setting up nvim"
if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "==> Setting up Zed"
if [ ! -d "$ZED_CONFIG_DIR" ]; then
    mkdir -p "$ZED_CONFIG_DIR"
fi
link_file "$DOTFILES_DIR/zed/settings.json" "$ZED_CONFIG_DIR/settings.json"
link_file "$DOTFILES_DIR/zed/keymap.json" "$ZED_CONFIG_DIR/keymap.json"

echo "==> Setting up keyd"
if [ ! -d "/etc/keyd" ]; then
    sudo mkdir -p "/etc/keyd"
fi
privileged_link_file "$DOTFILES_DIR/keyd/default.conf" "/etc/keyd/default.conf"

sudo systemctl enable keyd && echo "[INFO] keyd service enabled"
sudo systemctl restart keyd && echo "[INFO] keyd service restarted"

echo "==> Setting up SSH agent"
if ! systemctl --user is-enabled ssh-agent.socket >/dev/null 2>&1; then
    systemctl --user enable ssh-agent.socket && echo "[INFO] ssh-agent.socket enabled"
else
    echo "[INFO] ssh-agent.socket already enabled"
fi

if ! systemctl --user is-active ssh-agent.socket >/dev/null 2>&1; then
    systemctl --user start ssh-agent.socket && echo "[INFO] ssh-agent.socket started"
else
    echo "[INFO] ssh-agent.socket already running"
fi

echo "==> Loading SSH keys"
if [ -d "$HOME/.ssh" ]; then
    echo "[INFO] Waiting for SSH socket to be ready..."
    for i in {1..5}; do
        if [ -S "$SSH_AUTH_SOCK" ]; then
            break
        fi
        sleep 1
    done

    keyCount=0
    for pubKey in "$HOME/.ssh"/*.pub; do
        if [ ! -f "$pubKey" ]; then
            continue
        fi

        privateKey="${pubKey%.pub}"
        if [ ! -f "$privateKey" ]; then
            echo "[WARN] Found $pubKey but no corresponding private key"
            continue
        fi

        if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$pubKey" | awk '{print $2}')"; then
            echo "[INFO] Adding SSH key: $privateKey"
            ssh-add "$privateKey" 2>/dev/null && keyCount=$((keyCount + 1)) || echo "[WARN] Failed to add $privateKey (may require passphrase)"
        else
            echo "[INFO] $privateKey already added"
        fi
    done

    echo "==> Listing loaded SSH keys"
    if [ $keyCount -gt 0 ]; then
        echo "[INFO] Loaded $keyCount SSH key(s)"
        echo "[INFO] Currently loaded SSH keys:"
        ssh-add -l
    else
        echo "[WARN] No keys loaded (they may require passphrases)"
        ssh-add -l || echo "[INFO] Run 'ssh-add ~/.ssh/key_name' to add keys with passphrases"
    fi
else
    echo "[WARN] No ~/.ssh directory found, skipping key loading"
fi

echo "==> Done"
