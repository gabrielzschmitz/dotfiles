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
    tailscale
    display
    fish
    nvim
    overlays
    home-manager
    st
    dmenu
    tomato-c
  ];

  mkHost =
    hostModule: extraModules:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ hostModule ] ++ sharedModules ++ extraModules;
    };
in
{
  flake.modules.nixos.vm =
    { pkgs, ... }:
    {
      imports = [ ../hosts/vm/hardware-configuration.nix ];

      networking.hostName = "vm";

      system.stateVersion = "26.05";

      boot.kernelPackages = pkgs.linuxPackages_hardened;

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

      services.udev.packages = with pkgs; [ pipette ];

      environment.systemPackages = with pkgs; [ pipette ];

      networking.hostName = "machine";

      system.stateVersion = "26.05";

      # Track the newest stable upstream kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      my.display = {
        picom = {
          enable = true;
          backend = "glx";
        };

        # Default discrete-GPU mode: the external monitor is driven directly by
        # the NVIDIA GPU at 1920x1080@239.96, rotated 180 degrees, primary and
        # left-aligned at the top. The internal panel is zoomed so 2560x1600
        # scaled by 0.675 becomes 1728x1080, matching the external height while
        # keeping the laptop's text at its former 144 dpi size.
        framebuffer = "3648x1080";

        outputs = [
          {
            name = "HDMI-0";
            mode = "1920x1080";
            rate = "239.96";
            rotation = "inverted";
            position = "0x0";
            primary = true;
            external = true;
          }
          {
            name = "eDP-1-1";
            mode = "2560x1600";
            rate = "240";
            rotation = "normal";
            position = "1920x0";
            scale = "0.675x0.675";
          }
        ];

        # Used when HDMI-0 is not connected: the internal panel alone, at the
        # same zoom, filling the 1728x1080 framebuffer.
        fallbackFramebuffer = "1728x1080";
        fallbackOutputs = [
          {
            name = "eDP-1-1";
            mode = "2560x1600";
            rate = "240";
            rotation = "normal";
            position = "0x0";
            scale = "0.675x0.675";
            primary = true;
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
    self.modules.nixos.damx
  ];
}
