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

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      };

      qt = {
        enable = true;

        platformTheme.name = "qtct";
        style.name = "fusion";

        qt5ctSettings = {
          Appearance = {
            color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/OneDark.conf";
            custom_palette = true;
            icon_theme = "OneDarkIcons";
            style = "fusion";
          };
        };

        qt6ctSettings = {
          Appearance = {
            color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/OneDark.conf";
            custom_palette = true;
            icon_theme = "OneDarkIcons";
            style = "fusion";
          };
        };
      };

      xdg.configFile = {
        "qt5ct/colors/OneDark.conf".source = "${pkgs.one-dark-gtk}/share/qt/qt5ct-colors.conf";

        "qt6ct/colors/OneDark.conf".source = "${pkgs.one-dark-gtk}/share/qt/qt6ct-colors.conf";
      };

      home.packages = with pkgs; [
        libsForQt5.qt5ct
        kdePackages.qt6ct
      ];
    };
}
