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

Review `modules/hosts.nix`, `modules/users.nix`, and `flake.nix` to ensure the
hostname, user, and hardware configuration are correct.

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

| Component                                         | Purpose                                                    |
| ------------------------------------------------- | ---------------------------------------------------------- |
| NixOS                                             | System configuration, services, and packages               |
| Nix Flakes                                        | Reproducible configuration inputs and outputs              |
| flake-parts                                       | Modular flake outputs and per-system settings              |
| import-tree                                       | Automatic module discovery under `modules/`                |
| Home Manager                                      | User packages, programs, and shell configuration           |
| [dwm](https://github.com/gabrielzschmitz/dwm)     | Dynamic window manager                                     |
| [st](https://github.com/gabrielzschmitz/st)       | Simple terminal                                            |
| [dmenu](https://github.com/gabrielzschmitz/dmenu) | Dynamic menu                                               |
| Ly                                                | TTY display manager                                        |
| Limine                                            | Bootloader                                                 |
| Neovim                                            | Editor and plugin configuration                            |
| Dunst                                             | Notification daemon                                        |
| Zen Browser                                       | Browser with declarative profile, policies, and extensions |

### Architecture

The configuration follows the dendritic pattern. `flake.nix` delegates to
`flake-parts` and `import-tree`, which imports every `.nix` file under
`modules/`. Each module exposes one or more aspects through
`flake.modules.nixos.*` or `flake.modules.homeManager.*`.

Feature modules that touch both system and user configuration, such as
`display.nix`, `dwm.nix`, `st.nix`, `fish.nix`, `nvim.nix`, and `users.nix`,
define both aspects in one file when appropriate. Host and user selection
remain explicit in `modules/hosts.nix` and `modules/home-manager.nix`.

### Project Structure

```text
.dotfiles/
├── flake.nix                     # Flake inputs and mkFlake entrypoint
├── flake.lock                    # Pinned dependency revisions
├── hosts/
│   └── nixos/
│       └── hardware-configuration.nix
├── modules/                      # Auto-imported dendritic modules
│   ├── flake.nix                 # Systems and formatter
│   ├── overlays.nix              # Custom package overlay
│   ├── hosts.nix                 # Host composition and nixosConfigurations
│   ├── home-manager.nix          # Home Manager integration and aspect selection
│   ├── users.nix                 # System user and Home Manager identity
│   ├── audio.nix                 # PipeWire
│   ├── boot.nix                  # Limine bootloader
│   ├── display.nix               # X11, Ly, picom and TTY palette
│   ├── dwm.nix                   # dwm window manager
│   ├── st.nix                    # st terminal
│   ├── dmenu.nix                 # dmenu
│   ├── locale.nix                # Timezone and locale
│   ├── network.nix               # NetworkManager
│   ├── virtualisation.nix        # QEMU guest and SPICE agent
│   ├── nix.nix                   # Flakes, unfree packages and binsh
│   ├── packages.nix              # System packages and printing
│   ├── fish.nix                  # System and user Fish configuration
│   ├── nvim.nix                  # Root and user Neovim configuration
│   ├── desktop.nix               # GUI and desktop packages
│   ├── dev.nix                   # Languages, editors and development tools
│   ├── formatters.nix            # Formatters and linters
│   ├── cli.nix                   # Command-line utilities
│   ├── fonts.nix                 # Custom font and fontconfig defaults
│   ├── git.nix                   # Git
│   ├── gpg.nix                   # GPG and gpg-agent
│   ├── ssh.nix                   # SSH and ssh-agent
│   ├── dunst.nix                 # Dunst notification daemon
│   ├── fastfetch.nix             # Fastfetch
│   ├── services.nix              # User services (SPICE clipboard)
│   ├── xdg.nix                   # XDG user directories
│   ├── zen.nix                   # Zen Browser profile, policies and extensions
│   └── craftapps.nix             # Craft apps configuration
├── pkgs/                         # Custom packages, exposed via an overlay
│   ├── default.nix               # Overlay (sfmono-nerd-font)
│   └── sfmono-nerd-font/{default.nix, fonts/*.otf}
├── configs/                      # Raw configuration files
│   ├── nvim/init.lua             # Neovim configuration
│   ├── fish/prompt.fish          # Shared fish prompt
│   ├── dunst/dunstrc             # Dunst notification configuration
│   ├── picom/picom.conf          # Picom compositor configuration
│   └── Xresources                # X resources (fonts, colors, st)
└── .gitignore
```

The exact tree may change as the configuration evolves.

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
