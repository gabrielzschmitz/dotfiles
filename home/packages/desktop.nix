{
  pkgs,
  zen-browser,
  ...
}:

{
  home.packages = with pkgs; [
    # Browser
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Window manager / terminal
    dmenu
    st

    # Documents
    zathura

    # File manager
    thunar

    # Cloud
    nextcloud-client

    # LaTeX
    (texliveSmall.withPackages (
      ps: with ps; [
        latexmk
      ]
    ))
  ];
}
