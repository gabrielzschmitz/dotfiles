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

      # Auto optimize nix-store at every build
      nix.settings.auto-optimise-store = true;
      # Auto garbage collect every week
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # /bin/sh -> dash
      environment.binsh = "${pkgs.dash}/bin/dash";
    };
}
