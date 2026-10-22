{ inputs, ... }:

{
  flake.overlays.default = import ../pkgs;

  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
}
