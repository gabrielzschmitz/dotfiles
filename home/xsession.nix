{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    xwallpaper
    xorg.xrandr
  ];

  home.activation.createWallDir = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/pic/wall"
  '';

  home.file.".xinitrc".executable = true;
  home.file.".xinitrc".text = ''
    #!/bin/sh
    xrandr --output Virtual-1 --primary --mode 1920x1080
    xwallpaper --zoom "$HOME/pic/wall/icelandiclandscape.jpeg"
    exec dwm
  '';
}
