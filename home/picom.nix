{ pkgs, ... }:

{
  # Picom compositor
  home.packages = [ pkgs.picom ];
  home.file.".config/picom/picom.conf".source = ../configs/picom/picom.conf;
}
