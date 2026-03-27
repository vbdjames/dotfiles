#!/usr/bin/env bash
set -euo pipefail

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Wire up shell config
echo 'source /workspaces/dotfiles/zsh/.zshrc' > ~/.zshrc
echo 'source /workspaces/dotfiles/zsh/.zsh_aliases' >> ~/.zshrc
echo 'source /workspaces/dotfiles/zsh/.zsh_prompt' >> ~/.zshrc

# Wire up tmux config
mkdir -p ~/.config/tmux
ln -sf /workspaces/dotfiles/tmux/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf

# Set zsh as default shell
chsh -s $(which zsh) root
