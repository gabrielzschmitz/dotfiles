{ inputs, ... }:

{
  flake.modules.homeManager.gui-theme =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      atomOneDark = pkgs.stdenvNoCC.mkDerivation {
        pname = "atom-one-dark-theme";
        version = "unstable";

        src = pkgs.fetchFromGitHub {
          owner = "UnnatShaneshwar";
          repo = "AtomOneDarkTheme";
          rev = "main";
          hash = "sha256-JbE9uVtlIIb0ei/XuZ2/Ccl3W2SyTYYLZgkbaXf9P2A=";
        };

        installPhase = ''
          runHook preInstall

          themeDir="$out/share/themes/AtomOneDark"
          mkdir -p "$themeDir"

          cp -r gtk-2.0 gtk-3.0 gtk-3.20 index.theme "$themeDir/"

          # GTK 3.20 references this shared assets directory.
          cp -r assets "$themeDir/"

          runHook postInstall
        '';
      };
    in
    {

      gtk = {
        enable = true;

        theme = {
          name = "AtomOneDark";
          package = atomOneDark;
        };

        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

          extraConfig = ''
            gtk-application-prefer-dark-theme = 1
          '';
        };

        gtk3 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = true;
          };
        };
      };

      home.packages = [
        pkgs.libsForQt5.qt5ct
      ];

      xdg.configFile."qt5ct/qt5ct.conf".text = ''
        [Appearance]
        style=gtk2
      '';

      home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
    };
}
