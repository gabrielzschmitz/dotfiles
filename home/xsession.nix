{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    xwallpaper
    xrandr
    xinit
    xrdb
  ];

  home.activation.createWallDir = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/pic/wall"
  '';

  home.activation.createStateDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/state/xauth" "$HOME/.local/state"
  '';

  home.file.".config/X11/Xresources".source = ../configs/Xresources;

  home.file.".xinitrc".executable = true;
  home.file.".xinitrc".text = ''
    #!/bin/sh
    xrdb -merge "$HOME/.config/X11/Xresources"
    xrandr --output Virtual-1 --primary --mode 1920x1080
    xwallpaper --zoom "$HOME/pic/wall/icelandiclandscape.jpeg"
    picom -b --config "$HOME/.config/picom/picom.conf"
    exec dwm 2> "$HOME/.local/state/xsession-errors"
  '';
}
