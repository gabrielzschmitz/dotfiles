{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  libXft,
  libXi,
  pinentry-curses,
  libassuan,
  libgpg-error,
  libconfig,
  gpgme,
  xorgproto,
}:

stdenv.mkDerivation rec {
  pname = "pinentry-dmenu";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "ritze";
    repo = "pinentry-dmenu";
    rev = version;
    sha256 = "sha256-FmP9tI/oU7VM8x+Wu6bbeg1CVopZc6oOWnd4qUptVV8=";
  };

  buildInputs = [ libX11 libXinerama libXft libXi pinentry-curses libassuan libgpg-error libconfig gpgme xorgproto ];

  preBuild = ''
    cp ${./config.h} config.h
    cp ${./src/pinentry-dmenu.c} pinentry-dmenu.c
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Pinentry implementation based on dmenu";
    homepage = "https://github.com/ritze/pinentry-dmenu";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    mainProgram = "pinentry-dmenu";
  };
}
