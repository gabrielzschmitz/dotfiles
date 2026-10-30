# NixOS Dotfiles

My personal NixOS configuration, managed declaratively with **Nix Flakes** and
**Home Manager**.

The setup includes a custom **dwm** window manager, **st** terminal, **Ly**
display manager, **Limine** bootloader, and a Neovim configuration. System and
user-level packages, services, and configuration are managed through Nix.

It defines two hosts: `vm` for the current QEMU guest and `machine` for an
Acer Predator Helios Neo 16S AI (PHN16S-71) with an Intel Core Ultra 9 275HX
and an NVIDIA GeForce RTX 5070 Ti Mobile.

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

| Host      | Hardware                                                                                  |
| --------- | ----------------------------------------------------------------------------------------- |
| `vm`      | Current virtual machine (QEMU guest, SPICE, `Virtual-1`)                                  |
| `machine` | Acer Predator Helios Neo 16S AI (PHN16S-71), Intel Core Ultra 9 275HX, RTX 5070 Ti Mobile |

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

## Keys

GPG and GitHub SSH keys are **not stored in this repository**. They are kept
separately in the password store and must be manually restored when setting up
a new installation.

The Nix modules (`modules/gpg.nix` and `modules/ssh.nix`) configure the
respective agents and reference the expected key locations. They do not manage
or provision the keys themselves.

### GPG

GPG uses `~/.local/share/gnupg` as its home directory, configured through
`programs.gpg.homedir`.

Git uses OpenPGP for commit and tag signing. To restore signing functionality,
import the public and private keys from the password store:

```sh
# Import the public key.
gpg --batch --import /path/to/public-key.asc

# Import the private key.
gpg --batch --import /path/to/private-key.asc

# Set the appropriate owner trust for the imported key.
# Replace the placeholder with the key's full fingerprint.
printf '<FINGERPRINT>:6:\n' | gpg --import-ownertrust

# Verify the imported secret key.
gpg --list-secret-keys --keyid-format=long
```

Verify that the secret key is available and that its associated identity has
the expected trust level.

The secret key is passphrase-protected. `gpg-agent` handles passphrase requests
through `pinentry-dmenu`.

### GitHub SSH

`modules/ssh.nix` configures GitHub to use a dedicated Ed25519 identity with
`IdentitiesOnly = yes`.

Restore the key pair from the password store:

```sh
# Create the SSH directory with restricted permissions.
install -d -m 700 ~/.ssh

# Install the private and public keys.
install -m 600 /path/to/private-key ~/.ssh/github_ed25519
install -m 644 /path/to/public-key ~/.ssh/github_ed25519.pub

# Verify the installed public key.
ssh-keygen -lf ~/.ssh/github_ed25519.pub

# Test authentication with GitHub.
ssh -T git@github.com
```

The public key must be registered with the appropriate GitHub account before
SSH authentication will succeed.

To register or replace a key, retrieve its public counterpart from the password
store and add it through:

<https://github.com/settings/ssh/new>

### Key Management

- Never commit private keys, public keys, fingerprints, or other key-specific
  identifiers to this repository.
- Keep key material in the password store, which is synchronized separately.
- Restore keys manually on new installations.
- When rotating a key, generate a new pair, update the password store,
  reinstall the key, and register the new public key with GitHub.
- Keep file permissions restricted, especially for private keys.

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

The `rebuild`, `reswitch`, `reupdate`, and `reclean` shell aliases are also
configured in Home Manager. They resolve the running hostname when invoked, so
they target `#vm` or `#machine` automatically. `reclean` removes old system
generations, collects garbage, then switches the current host.

---

## Configuration

| Component                                         | Purpose                                                       |
| ------------------------------------------------- | ------------------------------------------------------------- |
| NixOS                                             | System configuration, services, and packages                  |
| Nix Flakes                                        | Reproducible configuration inputs and outputs                 |
| flake-parts                                       | Modular flake outputs and per-system settings                 |
| import-tree                                       | Automatic module discovery under `modules/`                   |
| Home Manager                                      | User packages, programs, and shell configuration              |
| `vm` host                                         | QEMU guest with SPICE agents; picom disabled by default       |
| `machine` host                                    | Acer PHN16S-71 with PRIME offload, Steam, and DAMX            |
| [dwm](https://github.com/gabrielzschmitz/dwm)     | Dynamic window manager                                        |
| [st](https://github.com/gabrielzschmitz/st)       | Simple terminal                                               |
| [dmenu](https://github.com/gabrielzschmitz/dmenu) | Dynamic menu                                                  |
| nnn                                               | Nnn's Not Noice: Terminal file manager                        |
| Ly                                                | TTY display manager                                           |
| Limine                                            | Bootloader                                                    |
| NVIDIA                                            | Open kernel modules, modesetting, and PRIME offload           |
| Steam / Proton GE                                 | Games with `proton-ge-bin` and PRIME offload                  |
| DAMX / Linuwu-Sense                               | Acer fan, thermal, battery, and keyboard controls (`machine`) |
| Neovim                                            | Editor and plugin configuration                               |
| Dunst                                             | Notification daemon                                           |
| Zen Browser                                       | Browser with declarative profile, policies, and extensions    |

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
The machine additionally imports `nvidia`, `steam`, and `damx`; DAMX is not
part of the VM closure. The NVIDIA module also adds an `nvidia-only`
specialisation, which Limine lists under every generation next to the default
PRIME-offload entry.

### Acer controls (machine only)

The `machine` host imports `modules/damx.nix`; the `vm` host does not. DAMX
provides fan, thermal-profile, battery-limit, and keyboard-RGB controls for
Acer laptops. Both applications are vendored and built from source in this
repository:

- `pkgs/linuwu-sense` builds the `linuwu_sense` kernel module against
  `config.boot.kernelPackages`. The module is loaded at boot and `acer_wmi` is
  blacklisted so the drivers do not compete for the Acer WMI interface.
- `pkgs/damx` builds the .NET 9/Avalonia GUI with `buildDotnetModule` and
  packages the Python daemon separately. The Nix packages do not use DKMS,
  PyInstaller, the upstream setup scripts, or an `/opt/damx` installation.
  The upstream setup scripts are vendored for reference only.
- `damx-daemon.service` runs the daemon as root after
  `systemd-modules-load.service`.

The vendored sources are:

| Component         | Version / revision    | Location                |
| ----------------- | --------------------- | ----------------------- |
| DAMX              | `1.0.2-h1`, `1f88341` | `pkgs/damx/src`         |
| Linuwu-Sense fork | `d8ea437`             | `pkgs/linuwu-sense/src` |

The driver source includes local DMI entries for `Predator PHN16S-71` and
`Predator PHIN16S-71`, with the Predator v4/four-zone-keyboard quirk. Verify
the laptop's actual DMI name:

```sh
cat /sys/class/dmi/id/product_name
```

If it differs, add a matching DMI entry in
`pkgs/linuwu-sense/src/src/linuwu_sense.c` and rebuild.

Build or develop against the packages directly:

```sh
nix build .#damx .#damx-daemon .#linuwu-sense
nix develop .#damx
nix develop .#linuwu-sense
```

The GUI is installed as `damx`; the daemon is available as `damx-daemon`.
Runtime files remain compatible with upstream: `/var/run/DAMX.sock`,
`/var/log/DAMX_Daemon_Log.log`, `/etc/DAMX_Daemon/config.ini`,
`/var/run/DAMX-Daemon.pid`, and `/etc/modprobe.d/linuwu-sense.conf`.

If Secure Boot is enabled, the Nix-built `linuwu_sense.ko` must be signed with
a key enrolled in the firmware, or Secure Boot must be disabled. This
configuration does not sign the module automatically.

### Firmware boot order (machine only)

`nixos-rebuild` manages the Limine bootloader, while the UEFI firmware
independently maintains the boot entries and their priority.

The `machine` firmware previously placed the stale `Linux Boot Manager`
(`systemd-boot`) entry before Limine. This could cause the machine to boot an
outdated NixOS generation instead of the one managed by Limine.

The stale systemd-boot entry has been removed, and Limine is configured as the
first UEFI boot option.

Inspect the firmware configuration with:

```sh
sudo nix shell nixpkgs#efibootmgr -c efibootmgr
```

The expected configuration is:

```text
BootOrder: 0001,0000,2001,2002,2003
Boot0000* HDD0: ...
Boot0001* Limine ...
```

To restore this configuration manually:

```sh
# Remove the stale systemd-boot entry.
sudo nix shell nixpkgs#efibootmgr -c efibootmgr -b 0002 -B

# Make Limine the permanent first boot option.
sudo nix shell nixpkgs#efibootmgr -c efibootmgr -o 0001,0000,2001,2002,2003

# Verify the resulting configuration.
sudo nix shell nixpkgs#efibootmgr -c efibootmgr
```

The Limine entry must remain first in `BootOrder`. Unlike `BootNext`, which
only affects the next boot, `BootOrder` establishes the persistent boot
priority.

If the firmware recreates the systemd-boot entry or changes the boot order
after a reboot, repeat the configuration and check the firmware settings.

If Limine is missing entirely (for example, after a firmware update), rebuild
the bootloader:

```sh
sudo nixos-rebuild boot --flake ~/.dotfiles#machine
```

Then select Limine manually from the firmware boot menu (F12) if necessary.

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
│   ├── damx.nix                  # DAMX/Linuwu-Sense integration (machine only)
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
│   ├── default.nix               # Overlay
│   ├── sfmono-nerd-font/{default.nix, fonts/*.otf}
│   ├── damx/                     # .NET GUI, Python daemon and vendored source
│   │   ├── default.nix
│   │   ├── daemon.nix
│   │   ├── deps.json
│   │   └── src/
│   └── linuwu-sense/             # Kernel module with vendored source
│       ├── default.nix
│       └── src/
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
- **Keys:** GPG and GitHub SSH keys are not in the repository. Import them from
  the password store on every new install; see [Keys](#keys).
- **VM display:** Picom is disabled on `vm` and the guest forces the
  `Virtual-1` output to 1920x1080.
- **Machine display:** The external `HDMI-1-0` output runs at 1920x1080@239.96,
  rotated 180 degrees, primary, at `0x0`. The internal `eDP-1` panel runs at
  2560x1600@240 and is zoomed with `--scale 0.675x0.675` to 1728x1080 at
  `1920x0`, so the two screens share the same 1080 pixel height. Both are
  configured through `my.display.outputs` in `modules/hosts.nix`.
- **DPI scaling:** `Xft.dpi` is global to the session and cannot be set per
  output, so mixed-DPI setups have to scale one screen to match the other with
  `xrandr --scale`. Values above 1 shrink the content on that output and values
  below 1 zoom in; the surrounding outputs' `position` must match the resulting
  size. Do not scale the external display: it is wired to the NVIDIA GPU and
  driven through reverse PRIME, where transforms are not applied to the shared
  pixmap, so `--scale` only crops it to the top-left corner. Scale the internal
  `eDP-1` panel instead, which is driven by the Intel iGPU.
- **Boot order:** The machine firmware resets `BootOrder` on every boot, so
  `limine-bootnext.service` sets `BootNext` to Limine. If the machine still
  boots `systemd-boot` and the new generation is not used, see
  [Firmware boot order](#firmware-boot-order-machine-only).
- **Machine graphics:** The desktop runs on the Intel iGPU and games offload to
  the RTX 5070 Ti via PRIME. The bus IDs in `modules/nvidia.nix` match the
  laptop's `lspci` output.
- **NVIDIA-only boot entry:** Limine lists an `nvidia-only` specialisation under
  every generation. Select it to boot the same configuration with the discrete
  GPU as the only X11 device; the laptop MUX must be set accordingly.
- **Steam:** Steam is enabled with `proton-ge-bin` and inherits the PRIME
  offload environment, so Steam and its games render on the NVIDIA GPU.
- **Acer controls:** DAMX and Linuwu-Sense are installed only on `machine`.
  The kernel module is built against the configured kernel packages and is not
  managed by DKMS.
- **Secure Boot:** If enabled, sign `linuwu_sense.ko` with an enrolled key or
  disable Secure Boot before activating the `machine` configuration.
- **Lockfile:** Keep `flake.lock` committed to pin input revisions.
- **Review:** Inspect changes before activating a new system generation.
- **Home Manager:** It is integrated through the flake, so a separate Home
  Manager installation is unnecessary.
- **Rollback:** If a rebuild causes problems, select a previous generation from
  the boot menu or rebuild a known-good configuration.

## License

Unless otherwise specified, this repository is provided without an explicit
license. All rights reserved.

The vendored source trees under `pkgs/damx/src` and `pkgs/linuwu-sense/src`
retain their upstream GPL-3.0 licenses and copyright notices. Those terms apply
to the vendored code; the repository-wide statement above applies to the
remaining files.
