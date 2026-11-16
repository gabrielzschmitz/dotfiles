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

      # Flox CUDA binary cache (avoid local CUDA builds)
      nix.settings.substituters = [
        "https://cache.nixos.org"
        "https://cache.flox.dev"
      ];
      nix.settings.trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      ];
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
