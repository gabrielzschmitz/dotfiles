{ ... }:

{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Command-line utilities
        fastfetch
        imagemagick
        xclip
        tree
        unzip
        zip
        wget
        curl
        bat
        ripgrep
      ];
    };
}
