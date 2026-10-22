{
  stdenv,
  lib,
  makeWrapper,
  pkg-config,
  fontconfig,
  freetype,
  imlib2,
  libX11,
  libXinerama,
  libXrender,
  libXft,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  procps,
  xsetroot,
}:

stdenv.mkDerivation {
  pname = "dwm";
  version = "6.5";

  src = ./src;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
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
    install -Dm755 dwm $out/bin/dwm
    install -Dm755 ${./bar.sh} $out/bin/dwm-bar

    wrapProgram $out/bin/dwm-bar \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          gnused
          procps
          xsetroot
        ]
      }

    mkdir -p $out/share/man/man1
    sed "s/VERSION/$version/g" < dwm.1 > $out/share/man/man1/dwm.1
    chmod 644 $out/share/man/man1/dwm.1

    runHook postInstall
  '';
}
