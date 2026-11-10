{ ... }:

{
  flake.modules.nixos.desktop = {
    programs.dconf.enable = true;
  };

  flake.modules.homeManager.desktop =
    { inputs, pkgs, ... }:
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
        inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.fluxer
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
