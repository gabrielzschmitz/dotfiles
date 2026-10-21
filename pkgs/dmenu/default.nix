{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXinerama,
  libXft,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "dmenu";
  version = "5.4";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/dmenu-${version}.tar.gz";
    sha256 = "sha256-j7rOKghHqoD+hhBmsRglLcx7TKCgqPOpOvAtqPts1FM=";
  };

  buildInputs = [ libX11 libXinerama libXft zlib ];

  preBuild = ''
    cp ${./config.h} config.h
    cp ${./patches/paste-clipboard.patch} patches/paste-clipboard.patch || true
  '';

  patches = [
    ./patches/paste-clipboard.patch
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Dynamic menu for X";
    homepage = "https://tools.suckless.org/dmenu/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
