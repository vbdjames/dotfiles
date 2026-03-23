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
- 1Password credentials (to retrieve SSH keys)

---

## Step 1 — Install Kubuntu

1. Boot from the Kubuntu 25.10 USB installer
2. Follow the installer — set up disk, user account (`djames`), timezone
3. Select **minimal installation** to keep the base clean
4. Complete the install and reboot

---

## Step 2 — Initial system update

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo reboot
```

---

## Step 3 — Clone dotfiles via HTTPS

Clone using HTTPS for now — no SSH keys needed yet. After 1Password is set up
and keys are restored you will switch the remote to SSH.

```bash
git clone https://github.com/vbdjames/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

This will:

- Set the hostname to `sophie`
- Add third party apt repos (1Password, Chrome, Mozilla Firefox)
- Install all apt packages from `apt/packages.txt`
- Stow all config packages (zsh, git, ssh, kde, tmux)
- Change default shell to zsh
- Install all Flatpaks from `flatpaks/flatpaks.txt`

Log out and back in after it completes so zsh takes effect.

---

## Step 4 — Restore SSH keys from 1Password

1. Launch 1Password and sign in to your account
2. Find your SSH key secure note and copy the private key content
3. Save to `~/.ssh/id_ed25519` and set permissions:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/id_ed25519        # paste private key content
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```

4. Switch the dotfiles remote from HTTPS to SSH:

```bash
cd ~/dotfiles
git remote set-url origin git@github.com:vbdjames/dotfiles.git
```

---

## Step 5 — Configure Konsole

The default Konsole profile launches bash. Fix once after first login:

1. Open Konsole → **Settings** → **Manage Profiles**
2. Click **New**
3. Give it a name (e.g. `Default`)
4. Under **General**, set **Command** to `/usr/bin/zsh`
5. Click **OK**, select the new profile → **Set as Default**

Verify:

```bash
echo $0
# should return: zsh
```

---

## Step 6 — Configure 1Password

1. Launch 1Password and sign in to your account
2. Go to **Settings → Developer → SSH Agent** and enable it
3. Open Firefox and install the [1Password extension](https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/)
4. Open Chrome and install the [1Password extension](https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa)

---

## Step 7 — Configure Thunderbird

Thunderbird is installed as a Flatpak via `install.sh`. After launch:

1. Use the account setup wizard to add each account:
   - **Gmail accounts (x2)** — OAuth2, opens a Google sign-in popup
   - **Fastmail** — OAuth2 auto-detected
2. Enable unified inbox: **View → Folders → Unified Folders**

---

## Step 8 — Install DisplayLink drivers

1. Download the DisplayLink driver from https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
2. Run the installer:

```bash
chmod +x DisplayLink_USB_Graphics_Software_for_Ubuntu*.run
sudo ./DisplayLink_USB_Graphics_Software_for_Ubuntu*.run
```

3. Reboot and connect the dock — monitors should come up automatically

Verify:

```bash
systemctl status displaylink
lsmod | grep evdi
```

---

## Step 9 — KDE settings

Once KDE is configured to your liking, export and track the settings:

See [`kde/README.md`](kde/README.md) in the dotfiles repo for instructions.

---

## Known Issues

### DisplayLink — not yet verified on Kubuntu

The DisplayLink installer has been documented above but has not yet been tested
on this specific setup. If the dock monitors don't come up after installing:

1. Check the service: `systemctl status displaylink`
2. Check the module: `lsmod | grep evdi`
3. Check logs: `journalctl -u displaylink --since "5 minutes ago"`

On Kubuntu/Ubuntu, DisplayLink is officially supported and should work without
the kernel module complications experienced on Fedora Kinoite/ostree.

---

## Day-to-day reference

### System update

```bash
sudo apt-get update && sudo apt-get upgrade -y
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
