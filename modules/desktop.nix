{ lib, ... }:

{
  flake.modules.nixos.desktop =
    { config, ... }:
    {
      options.my.wallpaper = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/pic/wall/icelandiclandscape.jpeg";
        description = "Wallpaper path set by xwallpaper when the X session starts.";
      };

      config.programs.dconf.enable = true;
    };

  flake.modules.homeManager.desktop =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        # System
        pamixer
        pavucontrol
        brightnessctl
        maim
        arandr

        # File-related
        nsxiv
        mpv

        # Creative
        inkscape
        audacity

        # General
        fluxer
        discord
        signal-desktop
        nextcloud-client
        tor-browser
        ungoogled-chromium
        qalculate-gtk
      ];

      home.activation.copyWall = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/pic/wall"
        cp -rf --no-preserve=mode ${../wall}/. "$HOME/pic/wall/"
      '';
    };
}
