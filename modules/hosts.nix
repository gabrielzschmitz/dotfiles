{ inputs, self, ... }:

let
  lib = inputs.nixpkgs.lib;

  sharedModules = with self.modules.nixos; [
    user
    nix
    boot
    locale
    network
    audio
    packages
    craftapps
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

      primaryOutput = "Virtual-1";
    };
  };

  flake.modules.nixos.machine = {
    imports = [ ../hosts/machine/hardware-configuration.nix ];

    networking.hostName = "machine";

    system.stateVersion = "26.05";

    my.display = {
      picom = {
        enable = true;
        backend = "glx";
      };

      primaryOutput = null;
    };
  };

  flake.nixosConfigurations.vm = mkHost self.modules.nixos.vm [
    self.modules.nixos.virtualisation
    self.modules.nixos.home-manager-vm
  ];

  flake.nixosConfigurations.machine = mkHost self.modules.nixos.machine [
    self.modules.nixos.nvidia
    self.modules.nixos.steam
  ];
}
