{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "st";
  version = "0.9.3";

  src = pkgs.fetchFromGitHub {
    owner = "gh0stzk";
    repo = "st-terminal";
    rev = "2f0b43721cf726c1fd20dc6246549814b10ec39e";
    hash = "sha256-f4zkwdqi2c960uq4Kls/pUxaDpUeD5keRGfWCuTKagE=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    ncurses
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
  ];

  postPatch = ''
    cp ${./st/config.h} config.h
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp st $out/bin/
    chmod 755 $out/bin/st

    mkdir -p $out/share/man/man1
    sed "s/VERSION/$version/g" < st.1 > $out/share/man/man1/st.1
    chmod 644 $out/share/man/man1/st.1

    mkdir -p $out/share/terminfo
    TERMINFO=$out/share/terminfo tic -sx st.info

    runHook postInstall
  '';
}
