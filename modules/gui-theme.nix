{ ... }:

{
  flake.modules.homeManager.gui-theme =
    { config, pkgs, ... }:
    {
      gtk = {
        enable = true;

        theme = {
          name = "OneDarkTheme";
          package = pkgs.one-dark-gtk;
        };

        iconTheme = {
          name = "OneDarkIcons";
          package = pkgs.one-dark-gtk;
        };

        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        };
      };
    };
}
