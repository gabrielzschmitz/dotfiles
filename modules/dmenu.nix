{ inputs, ... }:

{
  flake.modules.nixos.dmenu = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.dmenu.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
