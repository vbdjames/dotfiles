# dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

---

## Repository structure

```
dotfiles/
├── install.sh                  # idempotent bootstrap — run this on a fresh install
├── .gitignore
│
├── apt/
│   └── packages.txt            # system packages to install via apt (Kubuntu)
│
├── zsh/                        # stow package → symlinks into ~
│   ├── .zshrc
│   ├── .zshenv
│   └── .zsh_aliases
│
├── git/                        # stow package → symlinks into ~
│   └── .gitconfig
│
├── ssh/                        # stow package → symlinks into ~
│   └── .ssh/
│       └── config              # SSH client config (NO keys — those stay in ~/.ssh)
│
├── kde/                        # stow package → symlinks into ~
│   └── README.md               # instructions for exporting your KDE settings
│
├── tmux/                       # stow package → symlinks into ~
│   └── .config/tmux/
│       └── tmux.conf
│
├── flatpaks/
│   └── flatpaks.txt            # list of Flatpak App IDs to install
│
└── system/
    └── hostname                # desired hostname for this machine
```

Each top-level directory (except `apt/`, `flatpaks/`, and `system/`) is a
**Stow package**. Stow mirrors the directory tree inside each package into `$HOME`,
creating symlinks. So `dotfiles/zsh/.zshrc` becomes `~/.zshrc`.

---

## Fresh install — step by step

See [RUNBOOK.md](RUNBOOK.md) for the complete step-by-step setup guide.

---

## Day-to-day usage

### Making a config change

Edit the file directly — because Stow created symlinks, the file you're editing
in `~/.zshrc` **is** the file in `~/dotfiles/zsh/.zshrc`.

```bash
# Edit live
nano ~/.zshrc

# See what changed
cd ~/dotfiles && git diff

# Commit and push
git add -p && git commit -m "zsh: add alias for kubectl" && git push
```

### Adding a system package

```bash
echo "package-name" >> apt/packages.txt
./install.sh --apt
git add apt/packages.txt && git commit -m "apt: add package-name"
```

### Adding a new Flatpak

```bash
echo "com.example.App" >> flatpaks/flatpaks.txt
./install.sh --flatpak
git add flatpaks/flatpaks.txt && git commit -m "flatpaks: add App"
```

### Re-stowing after adding new files

If you add a new config file to a package directory:

```bash
./install.sh --stow
```

### Machine-specific overrides

Some settings shouldn't be the same on every machine (work email, local paths, etc.).
These files are sourced by the tracked config but are **not** committed:

| File | Purpose |
|---|---|
| `~/.zshrc.local` | Machine-specific shell config, secrets, work aliases |
| `~/.gitconfig.local` | Override name/email (e.g. work identity) |

---

## Re-running on an existing system

`install.sh` is fully idempotent — safe to re-run anytime:

```bash
cd ~/dotfiles && git pull
./install.sh
```

Stow uses `--restow` so existing symlinks are refreshed. Apt packages already
installed are skipped. Flatpaks already installed are skipped.
