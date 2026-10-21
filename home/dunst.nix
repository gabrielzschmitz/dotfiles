{ pkgs, ... }:

{
  # Notification daemon
  home.packages = with pkgs; [
    dunst
    libnotify # notify-send
    adwaita-icon-theme # icon_theme = Adwaita in dunstrc
    xdg-utils # xdg-open for the notification context menu
  ];

  home.file.".config/dunst/dunstrc".source = ../configs/dunst/dunstrc;
}
