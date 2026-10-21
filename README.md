# NixOS Dotfiles

My personal NixOS configuration, managed declaratively with **Nix Flakes** and
**Home Manager**.

The setup includes a custom **dwm** window manager, **st** terminal, **Ly**
display manager, **Limine** bootloader, and a Neovim configuration. System and
user-level packages, services, and configuration are managed through Nix.

---

## Quick Start

### 1. Clone the repository

```sh
git clone https://github.com/gabrielzschmitz/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

For SSH:

```sh
git clone git@github.com:gabrielzschmitz/dotfiles.git ~/.dotfiles
```

### 2. Enable Flakes

On a fresh NixOS installation, enable the experimental features in
`/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [
  "nix-command"
  "flakes"
];
```

Apply the change using the existing system configuration:

```sh
sudo nixos-rebuild switch
```

If Git is not installed, you can temporarily run it through Nix:

```sh
nix-shell -p git
```

### 3. Configure the hardware

The repository's `hosts/nixos/hardware-configuration.nix` may not match the target machine.
Generate a hardware configuration for the current installation:

```sh
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hosts/nixos/hardware-configuration.nix
```

Review `hosts/nixos/default.nix` and `flake.nix` to ensure the hostname and
hardware configuration are correct.

### 4. Build and activate

<details open>
<summary><b>Automatic</b> &mdash; NixOS rebuild</summary>

Build and activate the system configuration, including the integrated Home
Manager setup:

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#nixos
```

The `nixos` suffix identifies the system configuration defined in the flake.
Change it if your flake uses a different hostname or configuration name.

</details>

<details>
<summary>Validate first &mdash; build without activating</summary>

```sh
sudo nixos-rebuild build --flake ~/.dotfiles#nixos
```

This builds the system closure without switching the running system to the new
configuration.

</details>

---

## Updating

Pull the latest changes and rebuild:

```sh
cd ~/.dotfiles
git pull --ff-only
sudo nixos-rebuild switch --flake ~/.dotfiles#nixos
```

To review pending changes before rebuilding:

```sh
git fetch
git diff HEAD..@{upstream}
```

The `rebuild` and `reswitch` shell aliases are also configured in Home Manager
to rebuild from `~/.dotfiles`.

---

## Configuration

| Component    | Purpose                                          |
| ------------ | ------------------------------------------------ |
| NixOS        | System configuration, services, and packages     |
| Nix Flakes   | Reproducible configuration inputs and outputs    |
| Home Manager | User packages, programs, and shell configuration |
| dwm          | Dynamic window manager                           |
| st           | Simple terminal                                  |
| Ly           | TTY display manager                              |
| Limine       | Bootloader                                       |
| Neovim       | Editor and plugin configuration                  |

### Project Structure

```text
.dotfiles/
├── flake.nix                     # Flake inputs and system outputs
├── flake.lock                    # Pinned dependency revisions
├── hosts/
│   └── nixos/
│       ├── default.nix           # Host-specific settings and module imports
│       └── hardware-configuration.nix
├── system/                       # NixOS modules, one domain per file
│   ├── default.nix               # Imports every system module
│   ├── boot.nix                  # Limine bootloader
│   ├── display.nix               # X11, dwm, Ly and TTY palette
│   ├── audio.nix                 # PipeWire
│   ├── network.nix               # NetworkManager
│   ├── locale.nix                # Timezone and locale
│   ├── virtualisation.nix        # QEMU guest and SPICE agent
│   ├── users.nix                 # User account and shell
│   ├── nix.nix                   # Flakes, unfree packages, binsh, XDG state
│   ├── packages.nix              # System packages and printing
│   └── root-nvim.nix             # Root Neovim activation script
├── home/                         # Home Manager modules
│   ├── default.nix               # User identity and module imports
│   ├── packages/
│   │   ├── dev.nix               # Languages, editors and development tools
│   │   ├── formatters.nix        # Formatters and linters
│   │   ├── cli.nix               # Command-line utilities
│   │   └── desktop.nix           # Browser, terminal, documents, GUI apps
│   ├── fonts.nix                 # Custom font and fontconfig defaults
│   ├── fish.nix                  # Fish shell configuration
│   ├── git.nix                   # Git
│   ├── gpg.nix                   # GPG and gpg-agent
│   ├── ssh.nix                   # SSH and ssh-agent
│   ├── nvim.nix                  # Neovim
│   ├── picom.nix                 # Picom compositor
│   ├── fastfetch.nix             # Fastfetch
│   ├── services.nix              # User services (SPICE clipboard)
│   ├── xdg.nix                   # XDG user directories
│   └── xsession.nix              # X11 init (xrandr, xwallpaper, picom, dwm)
├── pkgs/                         # Custom packages, exposed via an overlay
│   ├── default.nix               # Overlay (dwm-custom, st, sfmono-nerd-font)
│   ├── dwm/{default.nix, config.h}
│   ├── st/{default.nix, config.h}
│   └── sfmono-nerd-font/{default.nix, fonts/*.otf}
├── shells/
│   └── tomato-c.nix              # Development shell
├── configs/                      # Raw configuration files
│   ├── nvim/init.lua             # Neovim configuration
│   ├── fish/prompt.fish          # Shared fish prompt
│   ├── picom/picom.conf          # Picom compositor configuration
│   └── Xresources                # X resources (fonts, colors, st)
└── .gitignore
```

The exact tree may change as the configuration evolves.

---

## Home Directory / XDG

The home directory is kept XDG-compliant: base directories are set explicitly,
and tools that default to clutter in `$HOME` are redirected through
`home.sessionVariables` (written to `~/.config/environment.d/`).

### XDG base directories

Home Manager's `xdg` module sets these automatically:

| Variable          | Value            |
| ----------------- | ---------------- |
| `XDG_CONFIG_HOME` | `~/.config`      |
| `XDG_DATA_HOME`   | `~/.local/share` |
| `XDG_CACHE_HOME`  | `~/.cache`       |
| `XDG_STATE_HOME`  | `~/.local/state` |
| `XDG_BIN_HOME`    | `~/.local/bin`   |

### Relocated paths

| Tool           | Variable                    | Location                           |
| -------------- | --------------------------- | ---------------------------------- |
| Go             | `GOPATH` / `GOBIN`          | `~/.local/share/go`, `~/.local/bin`|
| npm            | `npm_config_cache`          | `~/.cache/npm`                     |
| Yarn           | `YARN_CACHE_FOLDER`         | `~/.cache/yarn`                    |
| Yarn           | `YARN_GLOBAL_FOLDER`        | `~/.local/share/yarn`              |
| GPG            | `programs.gpg.homedir`      | `~/.local/share/gnupg`             |
| xauth          | `XAUTHORITY`                | `~/.local/state/xauth/xauthority`  |
| ICE            | `ICEAUTHORITY`              | `~/.cache/ICEauthority`            |
| XCompose       | `XCOMPOSEFILE`              | `~/.config/X11/xcompose`           |
| Compose cache  | `XCOMPOSECACHE`             | `~/.cache/X11/xcompose`            |
| X resources    | `xrdb -merge` in session    | `~/.config/X11/Xresources`         |
| X session logs | `dwm` stderr redirect       | `~/.cache/X11/xsession-errors`     |
| Nix user state | `use-xdg-base-directories`  | `~/.local/state/nix`               |

`ICEAUTHORITY` lives under `XDG_CACHE_HOME` (not `XDG_RUNTIME_DIR`, which is only
available after login and would make display managers that start Xorg fail).

### Exceptions

The following intentionally remain in `$HOME`:

- `.ssh` — OpenSSH has no clean XDG relocation; keys and `known_hosts`
  are fixed relative to the home directory.
- `.nix-profile` — back-compat symlink kept by Nix even with
  `use-xdg-base-directories`.
- `.manpath` — a Home Manager symlink that man-db does not merge, so it cannot
  be relocated out of `$HOME`.
- `.gnupg` — only if GPG keys have not yet been migrated (see below).

### After switching

Migrate the GPG keyring and remove stale locations once the new generation is
active and you have logged in again:

```sh
# GPG keyring -> ~/.local/share/gnupg
systemctl --user stop gpg-agent.socket gpg-agent.service
mkdir -p ~/.local/share/gnupg
mv ~/.gnupg/* ~/.local/share/gnupg/ 2>/dev/null
rmdir ~/.gnupg 2>/dev/null

# Stale home-directory files
rm -f ~/.xsession-errors ~/.xsession-errors.old ~/.Xauthority ~/.ICEauthority
rm -rf ~/go ~/.npm ~/.yarnrc ~/.Xresources ~/.compose-cache
```

`~/.nix-defexpr` disappears automatically once `use-xdg-base-directories` is
active.

---

## Notes

- **Hardware:** Review `hardware-configuration.nix` before deploying to another
  machine.
- **Hostname:** Ensure `flake.nix` exports the configuration under the name
  used by `nixos-rebuild`.
- **Lockfile:** Keep `flake.lock` committed to pin input revisions.
- **Review:** Inspect changes before activating a new system generation.
- **Home Manager:** It is integrated through the flake, so a separate Home
  Manager installation is unnecessary.
- **Rollback:** If a rebuild causes problems, select a previous generation from
  the boot menu or rebuild a known-good configuration.

## License

Unless otherwise specified, this repository is provided without an explicit
license. All rights reserved.
