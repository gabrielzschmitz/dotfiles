{ pkgs, ... }:

{
  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.binsh = "${pkgs.dash}/bin/dash";
}
