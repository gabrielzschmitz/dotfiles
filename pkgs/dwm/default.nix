{
  stdenv,
  pkg-config,
  fontconfig,
  freetype,
  imlib2,
  libX11,
  libXinerama,
  libXrender,
  libXft,
}:

stdenv.mkDerivation {
  pname = "dwm";
  version = "6.5";

  src = ./src;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    imlib2
    libX11
    libXinerama
    libXrender
    libXft
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp dwm $out/bin/dwm
    chmod 755 $out/bin/dwm

    mkdir -p $out/share/man/man1
    sed "s/VERSION/$version/g" < dwm.1 > $out/share/man/man1/dwm.1
    chmod 644 $out/share/man/man1/dwm.1

    runHook postInstall
  '';
}
