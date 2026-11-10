{ inputs, ... }:

{
  flake.overlays.default = final: prev: (import ../pkgs { inherit inputs; }) final prev;

  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
}
