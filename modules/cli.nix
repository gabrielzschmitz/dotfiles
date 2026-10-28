{ ... }:

{
  flake.modules.homeManager.cli =
    { configs, pkgs, ... }:
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
        zip
        unzip
        gnutar
        gzip
        bzip2
        xz
        p7zip
        wget
        curl
        bat
        ripgrep
        devour
        gdu
      ];

      xdg.configFile."gdu/gdu.yaml".source = ../configs/gdu/gdu.yaml;
    };
}
