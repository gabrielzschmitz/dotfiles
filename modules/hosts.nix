{ inputs, self, ... }:

let
  lib = inputs.nixpkgs.lib;

  sharedModules = with self.modules.nixos; [
    user
    nix
    boot
    locale
    network
    bluetooth
    audio
    packages
    craftapps
    thunar
    display
    fish
    nvim
    overlays
    home-manager
    st
    dmenu
  ];

  mkHost =
    hostModule: extraModules:
    lib.nixosSystem {
      modules = [ hostModule ] ++ sharedModules ++ extraModules;
    };
in
{
  flake.modules.nixos.vm = {
    imports = [ ../hosts/vm/hardware-configuration.nix ];

    networking.hostName = "vm";

    system.stateVersion = "26.05";

    boot.kernelParams = [ "video=Virtual-1:1920x1080@60" ];

    my.display = {
      picom = {
        enable = false;
        backend = "xrender";
      };

      outputs = [
        {
          name = "Virtual-1";
          mode = "1920x1080";
          primary = true;
        }
      ];
    };
  };

  flake.modules.nixos.machine =
    { pkgs, ... }:
    {
      imports = [ ../hosts/machine/hardware-configuration.nix ];

      networking.hostName = "machine";

      system.stateVersion = "26.05";

      my.display = {
        picom = {
          enable = true;
          backend = "egl";
        };

        # External monitor: 1920x1080@239.96, rotated 180 degrees, primary and
        # left-aligned at the top. This port is wired to the NVIDIA GPU and is
        # driven through reverse PRIME, where xrandr transforms are not applied
        # (scaling it only shows the top-left corner of the desktop), so it
        # always stays at its native size. The internal panel is zoomed instead:
        # 2560x1600 scaled by 0.675 becomes 1728x1080, matching the external
        # height while keeping the laptop's text at its former 144 dpi size.
        outputs = [
          {
            name = "HDMI-1-0";
            mode = "1920x1080";
            rate = "239.96";
            rotation = "inverted";
            position = "0x0";
            primary = true;
          }
          {
            name = "eDP-1";
            mode = "2560x1600";
            rate = "240";
            rotation = "normal";
            position = "1920x0";
            scale = "0.675x0.675";
          }
        ];
      };

      # The firmware resets BootOrder on every boot and puts the stale
      # systemd-boot entry before Limine. BootNext survives that reset, so set
      # it on every boot to make sure the next boot lands in Limine.
      systemd.services.limine-bootnext = {
        description = "Make Limine the next UEFI boot entry";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          entry=
          while IFS= read -r line; do
            if [[ $line =~ ^Boot([0-9A-Fa-f]{4})\*?\ Limine ]]; then
              entry="''${BASH_REMATCH[1]}"
              break
            fi
          done < <(${pkgs.efibootmgr}/bin/efibootmgr)

          if [[ -z $entry ]]; then
            echo "limine-bootnext: no Limine UEFI boot entry found" >&2
            exit 1
          fi

          ${pkgs.efibootmgr}/bin/efibootmgr -n "$entry"
        '';
      };
    };

  flake.nixosConfigurations.vm = mkHost self.modules.nixos.vm [
    self.modules.nixos.virtualisation
    self.modules.nixos.home-manager-vm
  ];

  flake.nixosConfigurations.machine = mkHost self.modules.nixos.machine [
    self.modules.nixos.desktop
    self.modules.nixos.nvidia
    self.modules.nixos.steam
    # self.modules.nixos.damx
  ];
}
