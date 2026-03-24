# ~/.zshrc
# Main zsh configuration.
# Machine-specific config goes in ~/.zshrc.local (not tracked in git).

# Load aliases
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Load local overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Prompt
[[ -f ~/.zsh_prompt ]] && source ~/.zsh_prompt
export PATH="$HOME/.local/bin:$PATH"
