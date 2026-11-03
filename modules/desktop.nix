{ ... }:

{
  flake.modules.nixos.desktop = {
    programs.dconf.enable = true;
  };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # System
        pamixer
        pavucontrol
        xbacklight
        maim
        arandr

        # File-related
        nsxiv
        mpv

        # Creative
        inkscape
        obs-studio
        audacity

        # General
        discord
        signal-desktop
        nextcloud-client
        qbittorrent
        tor-browser
        ungoogled-chromium
        qalculate-gtk
      ];
    };
}
