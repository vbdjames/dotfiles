# KDE Settings

KDE stores its configuration in `~/.config/` and `~/.local/share/`.
These files can be tracked in this repo by adding them to the `kde/` stow package.

## Exporting KDE settings

After configuring KDE to your liking, copy the relevant config files into this package:

```bash
# Example — Konsole profile
cp ~/.local/share/konsole/*.profile ~/dotfiles/kde/.local/share/konsole/

# Example — KDE global settings
cp ~/.config/kdeglobals ~/dotfiles/kde/.config/kdeglobals
```

Then stow the package:

```bash
cd ~/dotfiles && stow --restow kde
```

## What to track

Good candidates for tracking:
- `~/.config/kdeglobals` — theme, fonts, colours
- `~/.config/kwinrc` — window manager settings
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` — panel/desktop layout
- `~/.local/share/konsole/*.profile` — terminal profiles

## What NOT to track

Avoid tracking files that contain machine-specific paths, session data,
or frequently auto-updated cache files.
