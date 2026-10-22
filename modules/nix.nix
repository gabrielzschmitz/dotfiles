{ ... }:

{
  flake.modules.nixos.nix =
    { pkgs, ... }:
    {
      # Flakes
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Keep Nix user state under ~/.local/state instead of ~/.nix-*
      nix.settings.use-xdg-base-directories = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      environment.binsh = "${pkgs.dash}/bin/dash";
    };
}
