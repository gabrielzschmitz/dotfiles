{ inputs, self, ... }:

{
  flake.modules.nixos.host = {
    imports = [ ../hosts/nixos/hardware-configuration.nix ];

    networking.hostName = "nixos";

    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      host
      user
      nix
      boot
      locale
      network
      audio
      virtualisation
      packages
      craftapps
      display
      fish
      nvim
      overlays
      home-manager
    ];
  };
}
