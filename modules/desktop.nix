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
        pwvucontrol
        xbacklight
        maim

        # File-related
        pcmanfm
        zathura
        nsxiv
        mpv

        # Creative
        inkscape

        # General
        discord-canary
        nextcloud-client

        # LaTeX
        (texliveSmall.withPackages (
          ps: with ps; [
            latexmk
          ]
        ))
      ];
    };
}
