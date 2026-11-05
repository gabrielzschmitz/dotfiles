{ inputs, ... }:

{
  flake.modules.nixos.tomato-c = { pkgs, ... }:
    let
      tomato = inputs.tomato-c.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [
          pkgs.tinycc
          pkgs.autoPatchelfHook
        ];
        buildPhase = ''
          runHook preBuild
          make -C build PREFIX="$out" DATAPREFIX="$out/share/tomato" CC=tcc
          runHook postBuild
        '';
      });
    in
    {
      environment.systemPackages = [ tomato ];
    };
}
