{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "st-dev";

  nativeBuildInputs = with pkgs; [
    pkg-config
    ncurses
    gnumake
    gcc
    bear
    clang-tools
  ];

  buildInputs = with pkgs; [
    fontconfig
    freetype
    harfbuzz
    imlib2
    libX11
    libXext
    libXrender
    libXft
    ncurses
  ];

  shellHook = ''
    echo "[st-dev] Entered development shell for st"
    echo "[st-dev] Run 'bear -- make' to generate compile_commands.json for LSP"
    export PKG_CONFIG_PATH="${pkgs.fontconfig.dev}/lib/pkgconfig:${pkgs.freetype.dev}/lib/pkgconfig:${pkgs.harfbuzz.dev}/lib/pkgconfig:${pkgs.imlib2}/lib/pkgconfig:${pkgs.libX11.dev}/lib/pkgconfig:${pkgs.libXext.dev}/lib/pkgconfig:${pkgs.libXrender.dev}/lib/pkgconfig:${pkgs.libXft.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';
}
