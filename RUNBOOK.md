# Sophie — Setup Runbook

Fresh install runbook for the HP EliteBook 840 G8 running Kubuntu.

---

## Hardware

- **Machine**: HP EliteBook 840 G8
- **CPU/GPU**: Intel TigerLake, Iris Xe Graphics
- **Secure Boot**: disabled
- **Dock**: StarTech DisplayLink hub (see Known Issues)
- **Monitors**: one direct HDMI, two via DisplayLink dock

---

## Prerequisites

- Kubuntu 25.10 USB installer
- Internet connection
- 1Password credentials

---

## Step 1 — Install Kubuntu

1. Boot from the Kubuntu 25.10 USB installer
2. Follow the installer — set up disk, user account (`djames`), timezone
3. Select **minimal installation** to keep the base clean
4. Complete the install and reboot

---

## Step 2 — Initial system update

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

---

## Step 3 — Set up DisplayLink repo

The Synaptics APT repository keyring must be installed manually before running
the bootstrap, as the keyring package requires a browser download.

1. Download the **Synaptics APT Repository** keyring package from:
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

- Set the hostname to `sophie`
- Add third party apt repos (1Password, Chrome, Mozilla Firefox)
- Install all apt packages from `apt/packages.txt` including DisplayLink
- Install the DevPod CLI
- Install Claude Code
- Stow all config packages (zsh, git, ssh, kde, tmux)
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
2. Enable Remix Icons: Iconize -> Add predefined icon pack

---

## Step 8 — Verify DisplayLink

Connect the dock and verify the monitors come up:

```bash
systemctl status displaylink
lsmod | grep evdi
```

If monitors don't appear, check logs:

```bash
journalctl -u displaylink --since "5 minutes ago"
```

---

## Step 9 — KDE settings

Once KDE is configured to your liking, export and track the settings:

See [`kde/README.md`](kde/README.md) in the dotfiles repo for instructions.

---

## Known Issues

### DisplayLink — not yet verified on Kubuntu

The DisplayLink setup above has been documented but not yet tested on this
specific hardware. On Kubuntu/Ubuntu, DisplayLink is officially supported via
DKMS and should work without the kernel module complications experienced on
Fedora Kinoite/ostree.

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

### Check DisplayLink

```bash
systemctl status displaylink
lsmod | grep evdi
```
