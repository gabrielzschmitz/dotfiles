{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "one-dark-gtk";
  version = "1.0";

  src = ./theme;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/themes" "$out/share/icons"

    cp -r OneDarkTheme "$out/share/themes/"
    cp -r OneDarkIcons "$out/share/icons/"

    runHook postInstall
  '';

  meta = {
    description = "One Dark GTK theme and icon theme";
    homepage = "https://github.com/gabrielzschmitz/dotfiles";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
