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
        tailscale

        # File-related
        thunar
        xarchiver
        zathura
        nsxiv
        mpv

        # Creative
        inkscape
        obs-studio
        audacity

        # General
        discord-canary
        signal-desktop
        nextcloud-client
        qbittorrent
        tor-browser
        ungoogled-chromium

        # LaTeX
        (texliveSmall.withPackages (
          ps: with ps; [
            latexmk
          ]
        ))
      ];
    };
}
