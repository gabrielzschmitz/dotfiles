{
  stdenv,
  pkg-config,
  ncurses,
  fontconfig,
  freetype,
  harfbuzz,
  imlib2,
  libX11,
  libXext,
  libXrender,
  libXft,
}:

stdenv.mkDerivation {
  pname = "st";
  version = "0.9.3";

  src = ./src;

  nativeBuildInputs = [
    pkg-config
    ncurses
  ];

  buildInputs = [
    fontconfig
    freetype
    harfbuzz
    imlib2
    libX11
    libXext
    libXrender
    libXft
  ];

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
