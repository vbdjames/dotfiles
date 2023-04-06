if [ -f /opt/homebrew/share/antigen/antigen.zsh ]; then
  source /opt/homebrew/share/antigen/antigen.zsh
  antigen init $HOME/.antigenrc
  unalias rm
fi

# Add paths
export PATH=/usr/local/sbin:/usr/local/bin:${PATH}
export PATH="$HOME/bin:$PATH"

# Colorize terminal
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down


# Switch projects - stolen from garybernhardt
unalias p
function p() {
  local proj
  proj=$(find ~/proj -mindepth 2 -maxdepth 2 -type d | sed "s|$(realpath ~)/proj/||" | selecta)
  if [[ -n "$proj" ]]; then
    cd ~/proj/$proj
    if [[ -d ~/secrets/$proj ]]; then
      . ~/secrets/$proj/secrets.sh
    fi
  fi
}

if [ -f /opt/homebrew/bin/rtx ]; then
  eval "$(/opt/homebrew/bin/rtx activate zsh)"
fi

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

