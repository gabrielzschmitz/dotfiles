{
  appimageTools,
  fetchurl,
  lib,
  symlinkJoin,
}:

let
  pname = "agent-orchestrator";
  version = "0.15.3";

  src = fetchurl {
    url = "https://github.com/OrchestratorInc/agent-orchestrator/releases/download/v${version}/${pname}-linux-x64.AppImage";
    hash = "sha256-1IfZDfr2L20/tL6COcxPHm0HPY4d1lxwFriU50hd7HI=";
  };

  extracted = appimageTools.extract { inherit pname version src; };

  wrapped = appimageTools.wrapType2 {
    inherit pname version src;
  };
in
symlinkJoin {
  name = "${pname}-${version}";

  paths = [ wrapped ];

  postBuild = ''
    mkdir -p "$out/share/applications" \
      "$out/share/icons/hicolor/1024x1024/apps"

    cp "${extracted}/usr/share/icons/hicolor/1024x1024/apps/${pname}.png" \
      "$out/share/icons/hicolor/1024x1024/apps/${pname}.png"

    substitute "${extracted}/${pname}.desktop" \
      "$out/share/applications/${pname}.desktop" \
      --replace-fail "Exec=AppRun %U" "Exec=${pname} %U"
  '';

  meta = {
    description = "Plan, run and supervise fleets of coding agents from task to merged PR";
    homepage = "https://github.com/OrchestratorInc/agent-orchestrator";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
