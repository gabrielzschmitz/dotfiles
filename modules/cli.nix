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
        numlockx
        ffmpeg
        dragon-drop
        tree
        zip
        unzip
        gnutar
        gzip
        bzip2
        xz
        p7zip
        entr
        bc
        wget
        curl
        bat
        ripgrep
        devour
        gdu
        openvpn
        yt-dlp
      ];

      xdg.configFile."gdu/gdu.yaml".source = ../configs/gdu/gdu.yaml;
    };
}
