# NixOS Dotfiles

My personal NixOS configuration, managed declaratively with **Nix Flakes** and
**Home Manager**.

The setup includes a custom **dwm** window manager, **st** terminal, **Ly**
display manager, **Limine** bootloader, and a Neovim configuration. System and
user-level packages, services, and configuration are managed through Nix.

It defines two hosts: `vm` for the current QEMU guest and `machine` for an
Intel Core Ultra 9 275HX laptop with an NVIDIA RTX 5070 Ti Mobile.

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

The repository defines two hosts with separate hardware configurations:

| Host      | Hardware                                                        |
| --------- | --------------------------------------------------------------- |
| `vm`      | Current virtual machine (QEMU guest, SPICE, `Virtual-1`)        |
| `machine` | Intel Core Ultra 9 275HX + NVIDIA GeForce RTX 5070 Ti Mobile    |

`hosts/vm/hardware-configuration.nix` is committed for the VM.
`hosts/machine/hardware-configuration.nix` is a placeholder that intentionally
fails evaluation until it is generated on the laptop:

```sh
sudo nixos-generate-config --show-hardware-config \
  > ~/.dotfiles/hosts/machine/hardware-configuration.nix
```

Review `modules/hosts.nix`, `modules/users.nix`, and `flake.nix` to ensure the
hostnames, user, and hardware configuration are correct.

### 4. Build and activate

<details open>
<summary><b>Automatic</b> &mdash; NixOS rebuild</summary>

Build and activate the system configuration, including the integrated Home
Manager setup. Use the flake output for the host you are building:

```sh
# Current VM
sudo nixos-rebuild switch --flake ~/.dotfiles#vm

# Laptop
sudo nixos-rebuild switch --flake ~/.dotfiles#machine
```

The suffix identifies the `nixosConfigurations` output to deploy.

</details>

<details>
<summary>Validate first &mdash; build without activating</summary>

```sh
sudo nixos-rebuild build --flake ~/.dotfiles#vm
sudo nixos-rebuild build --flake ~/.dotfiles#machine
```

This builds the selected system closure without switching the running system to
the new configuration.

</details>

---

## Updating

Pull the latest changes and rebuild:

```sh
cd ~/.dotfiles
git pull --ff-only
sudo nixos-rebuild switch --flake ~/.dotfiles#vm      # or #machine
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

| Component                                         | Purpose                                                          |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| NixOS                                             | System configuration, services, and packages                     |
| Nix Flakes                                        | Reproducible configuration inputs and outputs                    |
| flake-parts                                       | Modular flake outputs and per-system settings                    |
| import-tree                                       | Automatic module discovery under `modules/`                      |
| Home Manager                                      | User packages, programs, and shell configuration                 |
| `vm` host                                         | QEMU guest with SPICE agents; picom disabled by default         |
| `machine` host                                    | Intel + NVIDIA laptop with PRIME offload and Steam               |
| [dwm](https://github.com/gabrielzschmitz/dwm)     | Dynamic window manager                                           |
| [st](https://github.com/gabrielzschmitz/st)       | Simple terminal                                                  |
| [dmenu](https://github.com/gabrielzschmitz/dmenu) | Dynamic menu                                                     |
| Ly                                                | TTY display manager                                              |
| Limine                                            | Bootloader                                                       |
| NVIDIA                                            | Open kernel modules, modesetting, and PRIME offload              |
| Steam / Proton GE                                 | Games with `proton-ge-bin` and PRIME offload                     |
| Neovim                                            | Editor and plugin configuration                                  |
| Dunst                                             | Notification daemon                                              |
| Zen Browser                                       | Browser with declarative profile, policies, and extensions       |

### Architecture

The configuration follows the dendritic pattern. `flake.nix` delegates to
`flake-parts` and `import-tree`, which imports every `.nix` file under
`modules/`. Each module exposes one or more aspects through
`flake.modules.nixos.*` or `flake.modules.homeManager.*`.

Feature modules that touch both system and user configuration, such as
`display.nix`, `dwm.nix`, `st.nix`, `fish.nix`, `nvim.nix`, and `users.nix`,
define both aspects in one file when appropriate. Host and user selection
remain explicit in `modules/hosts.nix` and `modules/home-manager.nix`.

`modules/hosts.nix` builds two `nixosConfigurations` from a shared module list.
VM-only modules (`virtualisation`, `home-manager-vm`) are imported only by `vm`.
The machine additionally imports `nvidia` and `steam`. The NVIDIA module also
adds an `nvidia-only` specialisation, which Limine lists under every generation
next to the default PRIME-offload entry.

### Project Structure

```text
.dotfiles/
├── flake.nix                     # Flake inputs and mkFlake entrypoint
├── flake.lock                    # Pinned dependency revisions
├── hosts/
│   ├── vm/
│   │   └── hardware-configuration.nix
│   └── machine/
│       └── hardware-configuration.nix  # Placeholder until generated on the laptop
├── modules/                      # Auto-imported dendritic modules
│   ├── flake.nix                 # Systems and formatter
│   ├── overlays.nix              # Custom package overlay
│   ├── hosts.nix                 # Host composition and nixosConfigurations
│   ├── home-manager.nix          # Home Manager integration and aspect selection
│   ├── users.nix                 # System user and Home Manager identity
│   ├── audio.nix                 # PipeWire
│   ├── boot.nix                  # Limine bootloader
│   ├── display.nix               # X11, Ly, display options and TTY palette
│   ├── dwm.nix                   # dwm window manager
│   ├── st.nix                    # st terminal
│   ├── dmenu.nix                 # dmenu
│   ├── locale.nix                # Timezone and locale
│   ├── network.nix               # NetworkManager
│   ├── virtualisation.nix        # QEMU guest and SPICE agent (vm only)
│   ├── nvidia.nix                # NVIDIA driver, PRIME and nvidia-only entry
│   ├── steam.nix                 # Steam, Proton GE and PRIME offload
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
│   ├── services.nix              # User services (SPICE clipboard, vm only)
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

- **Hardware:** Review the per-host `hardware-configuration.nix` before
  deploying. The machine file is a placeholder until generated on the laptop.
- **Hostnames:** The flake exports `vm` and `machine`; use the matching suffix
  with `nixos-rebuild`.
- **VM display:** Picom is disabled on `vm` and the guest forces the
  `Virtual-1` output to 1920x1080.
- **Machine graphics:** The desktop runs on the Intel iGPU and games offload to
  the RTX 5070 Ti via PRIME. The bus IDs in `modules/nvidia.nix` match the
  laptop's `lspci` output.
- **NVIDIA-only boot entry:** Limine lists an `nvidia-only` specialisation under
  every generation. Select it to boot the same configuration with the discrete
  GPU as the only X11 device; the laptop MUX must be set accordingly.
- **Steam:** Steam is enabled with `proton-ge-bin` and inherits the PRIME
  offload environment, so Steam and its games render on the NVIDIA GPU.
- **Lockfile:** Keep `flake.lock` committed to pin input revisions.
- **Review:** Inspect changes before activating a new system generation.
- **Home Manager:** It is integrated through the flake, so a separate Home
  Manager installation is unnecessary.
- **Rollback:** If a rebuild causes problems, select a previous generation from
  the boot menu or rebuild a known-good configuration.

## License

Unless otherwise specified, this repository is provided without an explicit
license. All rights reserved.
