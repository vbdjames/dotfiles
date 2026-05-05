#!/usr/bin/env bash
# Runs once after container creation.
# Installs core tools, applies dotfile symlinks, and sets zsh as the default shell.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Install the tools the dotfiles configure (skip GUI/desktop apps)
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends zsh neovim stow tmux

# Install lazygit (reuses idempotent logic from install.sh)
./install.sh --lazygit

# Apply dotfile symlinks
./install.sh --stow

# Set zsh as default shell
ZSH_PATH="$(command -v zsh)"
sudo usermod -s "$ZSH_PATH" vscode
