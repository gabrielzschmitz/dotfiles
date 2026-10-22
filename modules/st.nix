{ inputs, ... }:

{
  flake.modules.nixos.st = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.st.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
