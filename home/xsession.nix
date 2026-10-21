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
    xrandr --auto
    wp="$(find "$HOME/pic/wall" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n 1)"; [ -n "$wp" ] && xwallpaper --stretch "$wp"
    exec dwm
  '';
}
