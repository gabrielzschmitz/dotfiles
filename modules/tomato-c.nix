{ inputs, ... }:

{
  flake.modules.nixos.tomato-c = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.tomato-c.packages.${pkgs.stdenv.hostPlatform.system}.tcc
    ];
  };
}
