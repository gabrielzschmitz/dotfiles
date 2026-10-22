{ ... }:

{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Window manager / terminal
        dmenu

        # File-related
        thunar
        zathura
        nsxiv

        # Creative
        inkscape

        # Cloud
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
