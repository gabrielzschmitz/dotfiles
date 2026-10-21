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

The repository's `hardware-configuration.nix` may not match the target machine.
Generate a hardware configuration for the current installation:

```sh
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hardware-configuration.nix
```

Review `configuration.nix` and `flake.nix` to ensure the hostname and hardware
configuration are correct.

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
├── configuration.nix          # NixOS system configuration
├── hardware-configuration.nix # Machine-specific hardware settings
├── flake.nix                  # Flake inputs and system outputs
├── flake.lock                 # Pinned dependency revisions
├── home.nix                   # Home Manager configuration
├── dwm.nix                    # dwm package configuration
├── dwm/
│   └── config.h               # dwm source configuration
├── st.nix                     # st package configuration
├── st/
│   └── config.h               # st source configuration
├── nvim/
│   └── init.lua               # Neovim configuration
├── fonts/                     # Custom fonts
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
