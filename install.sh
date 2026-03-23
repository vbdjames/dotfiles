#!/usr/bin/env bash
# =============================================================================
# dotfiles/install.sh
# Idempotent bootstrap — safe to re-run at any time.
#
# Usage:
#   ./install.sh             # full bootstrap
#   ./install.sh --stow      # only (re)stow symlinks
#   ./install.sh --repos     # only set up third party apt repos
#   ./install.sh --apt       # only install apt packages
#   ./install.sh --flatpak   # only install Flatpaks
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_TARGET="$HOME"

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[info]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
error()   { echo -e "${RED}[error]${NC} $*" >&2; }

# ── Helpers ───────────────────────────────────────────────────────────────────
have() { command -v "$1" &>/dev/null; }

require() {
    if ! have "$1"; then
        error "Required command not found: $1"
        exit 1
    fi
}

# =============================================================================
# HOSTNAME
# Reads system/hostname and applies it if it differs from the current hostname.
# Idempotent — skips if already correct.
# =============================================================================
do_hostname() {
    local file="$DOTFILES_DIR/system/hostname"

    if [[ ! -f "$file" ]]; then
        warn "No system/hostname file found — skipping."
        return
    fi

    local desired
    desired=$(cat "$file" | xargs)

    if [[ -z "$desired" ]]; then
        warn "system/hostname is empty — skipping."
        return
    fi

    local current
    current=$(hostnamectl hostname)

    if [[ "$current" == "$desired" ]]; then
        info "Hostname already set to: $current — skipping."
    else
        info "Setting hostname: $current → $desired"
        sudo hostnamectl set-hostname "$desired"
    fi
}

# =============================================================================
# THIRD PARTY REPOS
# Adds vendor apt repos for software not in the standard Ubuntu repos.
# Idempotent — skips repos that are already configured.
# Note: DisplayLink repo requires a manual step — see RUNBOOK.md.
# =============================================================================
do_third_party_repos() {
    info "Setting up third party apt repos"

    if ! have apt; then
        warn "apt not found — skipping. Not a Debian/Ubuntu based system?"
        return
    fi

    # 1Password
    if [[ ! -f /etc/apt/sources.list.d/1password.list ]]; then
        info "  Adding 1Password repo"
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | sudo gpg --dearmor \
            | sudo tee /usr/share/keyrings/1password-archive-keyring.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" \
            | sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
    else
        info "  1Password repo already configured — skipping"
    fi

    # Google Chrome
    if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]; then
        info "  Adding Google Chrome repo"
        curl -sS https://dl.google.com/linux/linux_signing_key.pub \
            | sudo gpg --dearmor \
            | sudo tee /usr/share/keyrings/google-chrome-keyring.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
            | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
    else
        info "  Google Chrome repo already configured — skipping"
    fi

    # Mozilla Firefox (native deb, not snap)
    if [[ ! -f /etc/apt/sources.list.d/mozilla.list ]]; then
        info "  Adding Mozilla repo"
        sudo install -d -m 0755 /etc/apt/keyrings
        curl -sS https://packages.mozilla.org/apt/repo-signing-key.gpg \
            | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
        echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
            | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
        # Pin Mozilla repo to take priority over Ubuntu's snap redirect
        echo -e "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" \
            | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    else
        info "  Mozilla repo already configured — skipping"
    fi

    info "Third party repos complete."
}

# =============================================================================
# APT PACKAGES
# Reads apt/packages.txt — one package name per line.
# Lines starting with # are comments. Blank lines are ignored.
# Only runs on apt-based systems (Kubuntu etc.) — skips gracefully otherwise.
# =============================================================================
do_apt_packages() {
    info "Installing apt packages"

    if ! have apt; then
        warn "apt not found — skipping. Not a Debian/Ubuntu based system?"
        return
    fi

    local list="$DOTFILES_DIR/apt/packages.txt"

    if [[ ! -f "$list" ]]; then
        warn "No packages.txt found at $list — skipping."
        return
    fi

    sudo apt update -qq

    local packages=()
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        local pkg
        pkg=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -z "$pkg" ]] && continue
        packages+=("$pkg")
    done < "$list"

    if [[ ${#packages[@]} -gt 0 ]]; then
        sudo apt install -y "${packages[@]}" || \
            warn "Some packages failed to install — check output above"
    fi

    info "Apt packages complete."
}

# =============================================================================
# STOW — symlink all packages into $HOME
# Each subdirectory of dotfiles/ is a stow "package".
# Stow mirrors the directory tree under the package into $STOW_TARGET.
# e.g. dotfiles/zsh/.zshrc  →  ~/.zshrc
# =============================================================================
do_stow() {
    info "Stowing dotfiles into $STOW_TARGET"
    require stow

    # Packages to stow — add new directories here as you create them
    local packages=(
        zsh
        git
        kde
        ssh
        tmux
    )

    for pkg in "${packages[@]}"; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            info "  stow: $pkg"
            stow --restow \
                 --dir="$DOTFILES_DIR" \
                 --target="$STOW_TARGET" \
                 "$pkg"
        else
            warn "  skipping $pkg (directory not found)"
        fi
    done

    info "Stow complete."

    # SSH sockets dir required by ~/.ssh/config ControlPath setting
    mkdir -p "$HOME/.ssh/sockets"
    chmod 700 "$HOME/.ssh/sockets"
    info "SSH sockets directory ready."
}

# =============================================================================
# FLATPAKS
# Reads flatpaks/flatpaks.txt — one App ID per line.
# Lines starting with # are comments. Blank lines are ignored.
# Only installs missing Flatpaks; already-installed ones are skipped.
# =============================================================================
do_flatpaks() {
    info "Installing Flatpaks"
    require flatpak

    local list="$DOTFILES_DIR/flatpaks/flatpaks.txt"

    if [[ ! -f "$list" ]]; then
        warn "No flatpaks.txt found at $list — skipping."
        return
    fi

    # Ensure Flathub is present
    if ! flatpak remotes | grep -q flathub; then
        info "  Adding Flathub remote"
        flatpak remote-add --user --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    # Sync Flathub metadata so package lookups work
    info "  Refreshing Flathub metadata"
    flatpak update --appstream --user -y 2>/dev/null || true

    local installed
    installed=$(flatpak list --app --columns=application 2>/dev/null)

    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        local app_id
        app_id=$(echo "$line" | sed 's/#.*//' | xargs)
        [[ -z "$app_id" ]] && continue

        if echo "$installed" | grep -qx "$app_id"; then
            info "  already installed: $app_id"
        else
            info "  installing: $app_id"
            flatpak install --user --noninteractive flathub "$app_id" || \
                warn "  failed to install $app_id — skipping"
        fi
    done < "$list"

    info "Flatpaks complete."
}

# =============================================================================
# DEVPOD
# Installs the DevPod CLI binary from GitHub releases.
# Idempotent — skips if already installed.
# =============================================================================
do_devpod() {
    info "Installing DevPod CLI"
    if have devpod; then
        info "DevPod already installed ($(devpod version 2>/dev/null || echo 'unknown version')) — skipping."
        return
    fi
    local arch
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)
            warn "Unsupported architecture: $(uname -m) — skipping DevPod install."
            return
            ;;
    esac
    local url="https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-${arch}"
    info "  Downloading DevPod for linux-${arch}"
    curl -L -o /tmp/devpod "$url"
    sudo install -c -m 0755 /tmp/devpod /usr/local/bin/devpod
    rm -f /tmp/devpod
    info "DevPod installed: $(devpod version 2>/dev/null || echo 'ok')"
}

# =============================================================================
# CHANGE DEFAULT SHELL TO ZSH
# Only runs if the current shell is not already zsh.
# =============================================================================
do_shell() {
    local zsh_path
    zsh_path=$(command -v zsh 2>/dev/null || true)

    if [[ -z "$zsh_path" ]]; then
        warn "zsh not found in PATH — skipping shell change."
        warn "Install zsh first (via apt or your package manager)."
        return
    fi

    if [[ "$SHELL" == "$zsh_path" ]]; then
        info "Default shell is already zsh — skipping."
    else
        info "Changing default shell to zsh ($zsh_path)"
        sudo usermod -s "$zsh_path" "$USER"
        info "Shell changed. Log out and back in for it to take effect."
    fi

    if [[ -f "$HOME/.bash_profile" ]]; then
        if grep -q "# .bash_profile" "$HOME/.bash_profile"; then
            info "Removing stock .bash_profile so zsh is used at login"
            rm "$HOME/.bash_profile"
        else
            warn ".bash_profile exists but looks customised — leaving it alone"
            warn "If zsh doesn't load at login, check ~/.bash_profile manually"
        fi
    fi
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    info "dotfiles bootstrap starting"
    info "Dotfiles dir: $DOTFILES_DIR"
    echo

    case "${1:-all}" in
        --stow)      do_stow ;;
        --repos)     do_third_party_repos ;;
        --apt)       do_apt_packages ;;
        --flatpak)   do_flatpaks ;;
	--devpod)    do_devpod ;;
        all)
            do_hostname
            echo
            do_third_party_repos
            echo
            do_apt_packages
            echo
            do_devpod
	    echo
            do_stow
            echo
            do_shell
            echo
            do_flatpaks
            ;;
        *)
            error "Unknown option: $1"
            echo "Usage: $0 [--stow | --repos | --apt | --flatpak | --devpod]"
            exit 1
            ;;
    esac

    echo
    info "Bootstrap complete."
}

main "${@}"
