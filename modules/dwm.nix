{ inputs, ... }:

{
  flake.modules.nixos.dwm = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.dwm.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
