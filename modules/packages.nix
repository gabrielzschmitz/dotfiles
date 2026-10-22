{ ... }:

{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      # Printing
      services.printing.enable = true;

      # Minimal system-level tools
      environment.systemPackages = with pkgs; [
        neovim
        wget
        curl
        git
      ];
    };
}
