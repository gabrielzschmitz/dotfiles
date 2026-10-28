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
        xcolor
        xkill
        xset
        xsetroot
        xdotool
        tree
        unzip
        zip
        rar
        xar
        wget
        curl
        bat
        ripgrep
      ];
    };
}
