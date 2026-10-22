{ inputs, ... }:

{
  flake.modules.nixos.craftapps = {
    imports = [ inputs.nix-craftapps.nixosModules.default ];

    programs.craftapps = {
      enable = true;
      linkFonts = true;
    };
  };

  flake.modules.homeManager.craftapps = {
    imports = [ inputs.nix-craftapps.homeManagerModules.default ];

    programs.craftapps = {
      enable = true;
      apps = {
        photocraft.enable = true;
        filmcraft.enable = true;
        vectorcraft.enable = true;
        wordcraft.enable = true;
      };
    };
  };
}
