# Setup Runbook

Fresh install runbook for Ubuntu-based systems.

---

## Prerequisites

- Ubuntu-based installer USB (Ubuntu, Kubuntu, etc.)
- Internet connection
- 1Password credentials

---

## Step 1 — Install the OS

1. Boot from your Ubuntu-based installer
2. Follow the installer — set up disk, user account, timezone
3. Select **minimal installation** to keep the base clean
4. **Choose your hostname carefully.** The bootstrap uses it to automatically
   load machine-specific packages: if `apt/packages.<hostname>.txt` exists in
   this repo it will be installed alongside the base packages. Pick a short,
   memorable name and create a matching file in `apt/` for each machine you
   manage (e.g. `apt/packages.sophie.txt`).
5. Complete the install and reboot

---

## Step 2 — Initial system update

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

---

## Step 3 — Machine-specific pre-bootstrap steps

Some machines require manual setup before the bootstrap can run — typically a
third-party APT keyring that must be downloaded via a browser rather than curl.
Check whether your machine has any such requirements before continuing.

**sophie — DisplayLink:** The Synaptics APT repository keyring must be installed
before the bootstrap, as it requires a browser download.

1. Download the **Synaptics APT Repository** keyring from:
   https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
2. Install it:

```bash
sudo apt install ./synaptics-repository-keyring.deb
```

---

## Step 4 — Clone dotfiles via HTTPS

Clone using HTTPS for now — SSH keys will be set up via 1Password after the
bootstrap runs.

```bash
git clone https://github.com/vbdjames/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

This will:

- Add third party apt repos (1Password, Chrome, Mozilla Firefox)
- Install all apt packages from `apt/packages.txt` and `apt/packages.<hostname>.txt` if it exists
- Install the DevPod CLI
- Install Claude Code
- Install lazygit
- Stow all config packages (zsh, git, ssh, tmux, lazygit; and kde on KDE systems)
- Change default shell to zsh
- Install all Flatpaks from `flatpaks/flatpaks.txt`

Reboot after it completes:

```bash
sudo reboot
```

---

## Step 5 — Configure 1Password and SSH

1. Launch 1Password and sign in to your account
2. Go to **Settings → Developer → SSH Agent** and enable it
3. Add your SSH keys to 1Password
4. Switch the dotfiles remote from HTTPS to SSH:

```bash
cd ~/dotfiles
git remote set-url origin git@github.com:vbdjames/dotfiles.git
```

5. Verify SSH works:

```bash
ssh -T git@github.com
```

---

## Step 6 — Install browser extensions

**Firefox:**
- [1Password extension](https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/)

**Chrome:**
- [1Password extension](https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa)

---

## Step 7 — Configure Thunderbird

Thunderbird is installed as a Flatpak via `install.sh`. After launch:

1. Use the account setup wizard to add each account:
   - **Gmail accounts (x2)** — OAuth2, opens a Google sign-in popup
   - **Fastmail** — OAuth2 auto-detected
2. Enable unified inbox: **View → Folders → Unified Folders**

---

## Step 8 — Configure Obsidian

Obsidian is installed as a Flatpak via `install.sh`. After launch:

1. Use Obsidian Sync to add each vault:
   - Login (credentials are in 1Password)
   - Select each vault to be synced:
     - Sync all other types: ON
     - Active community plugins list: ON
     - Installed community plugins: ON
   - Close and re-open Obsidian
2. Enable Remix Icons: Iconize → Add predefined icon pack

---

## Step 9 — KDE settings *(KDE systems only)*

Once KDE is configured to your liking, export and track the settings:

See [`kde/README.md`](kde/README.md) in the dotfiles repo for instructions.

---

## Day-to-day reference

### System update

```bash
sudo apt update && sudo apt upgrade -y
```

### Re-run dotfiles bootstrap

```bash
cd ~/dotfiles && git pull && ./install.sh
```

### Check DisplayLink *(sophie)*

```bash
systemctl status displaylink
lsmod | grep evdi
```
