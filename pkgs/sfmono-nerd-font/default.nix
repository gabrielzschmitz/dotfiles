{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "sfmono-nerd-font";
  version = "1.0";

  src = ./fonts;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype/SFMonoNerdFont
    cp *.otf $out/share/fonts/opentype/SFMonoNerdFont/

    runHook postInstall
  '';
}
