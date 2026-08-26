#!/usr/bin/bash
# Symlink configs from this repo to ~/.config/
# Usage: ./install.sh

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

CONFIGS=(
    hypr
    alacritty
    kitty
    ghostty
    git
    omarchy
    tmux
    nvim
)

for config in "${CONFIGS[@]}"; do
    target="$HOME/.config/$config"
    source="$REPO_DIR/$config"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target -> ${target}.bak"
        mv "$target" "${target}.bak"
    elif [ -L "$target" ]; then
        rm "$target"
    fi

    ln -s "$source" "$target"
    echo "Linked $target -> $source"
done

# Handle starship.toml separately (file, not directory)
STARSHIP_TARGET="$HOME/.config/starship.toml"
STARSHIP_SOURCE="$REPO_DIR/starship.toml"

if [ -e "$STARSHIP_TARGET" ] && [ ! -L "$STARSHIP_TARGET" ]; then
    echo "Backing up $STARSHIP_TARGET -> ${STARSHIP_TARGET}.bak"
    mv "$STARSHIP_TARGET" "${STARSHIP_TARGET}.bak"
elif [ -L "$STARSHIP_TARGET" ]; then
    rm "$STARSHIP_TARGET"
fi

ln -s "$STARSHIP_SOURCE" "$STARSHIP_TARGET"
echo "Linked $STARSHIP_TARGET -> $STARSHIP_SOURCE"

# Reinstall third-party shell plugins listed in omarchy/plugins.txt.
# They are git clones, gitignored here, so a fresh checkout has none.
PLUGIN_MANIFEST="$REPO_DIR/omarchy/plugins.txt"

if [ -f "$PLUGIN_MANIFEST" ] && command -v omarchy >/dev/null; then
    while read -r url; do
        case "$url" in ''|\#*) continue ;; esac
        echo "Installing plugin $url"
        omarchy plugin add "$url" --enable --yes
    done < "$PLUGIN_MANIFEST"
fi

echo "Done! All configs symlinked."
