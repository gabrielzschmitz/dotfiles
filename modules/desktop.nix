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
        zathura
        mupdf
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
            # Build tools
            latexmk
            biber

            # Page layout and formatting
            geometry
            fancyhdr
            titlesec

            # Mathematics
            amsmath
            amsfonts

            # Links, colors, and graphics
            url
            hyperref
            xcolor
            graphics

            # Code listings
            minted
            fvextra
            fancyvrb
            catchfile
            etoolbox
            upquote
            lineno

            # Tables and lists
            booktabs
            paralist

            # Poetry and line numbering
            verse

            # Language and document utilities
            babel
            biblatex
          ]
        ))
      ];
    };
}
