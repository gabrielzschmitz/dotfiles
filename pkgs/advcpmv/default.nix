{
  lib,
  stdenv,
  fetchurl,
  perl,
  texinfo,
  acl,
  attr,
  gmp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "advcpmv";
  version = "0.9";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/coreutils/coreutils-9.11.tar.xz";
    hash = "sha256-OUAk7aCllVIXztqc0SAeZdyPo6opwpURNaSVIdV8PMM=";
  };

  patches = [
    (fetchurl {
      name = "advcpmv-0.9-9.11.patch";
      url = "https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.9-9.11.patch";
      hash = "sha256-VCR7Vy8BXqd1Dc4ayORdoHc2cW1iv8PyZzWRbLHAQm8=";
    })
  ];

  nativeBuildInputs = [
    perl
    texinfo
  ];
  buildInputs = [
    acl
    attr
    gmp
  ];

  configureFlags = [
    "--with-packager=https://nixos.org"
    "--disable-nls"
  ];

  enableParallelBuilding = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 src/cp "$out/bin/cpg"
    install -Dm755 src/mv "$out/bin/mvg"
    runHook postInstall
  '';

  meta = {
    description = "Coreutils cp and mv with a progress bar";
    homepage = "https://github.com/jarun/advcpmv";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "cpg";
  };
})
