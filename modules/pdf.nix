{ ... }:

{
  flake.modules.homeManager.pdf =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # PDF viewers
        zathura
        mupdf

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

      # Zathura configuration
      xdg.configFile."zathura/zathurarc".source = ../configs/zathurarc;
    };
}
