{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
}:

let
  pname = "pipette";
  version = "0.5.1";

  app = appimageTools.wrapType2 {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/darakuneko/pipette-desktop/releases/download/v${version}/Pipette-linux-x86_64.AppImage";
      sha256 = "sha256-bcsp4l88J6J0BGBy9aVKrB52MR7LZY37leA8GQB44HY=";
    };

    extraPkgs =
      pkgs: with pkgs; [
        libgpg-error
        libgcrypt
        gpgme
        libsecret
        glib
        gtk3
        webkitgtk_4_1
        libsoup_3
        libGL
        mesa
        vulkan-loader
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxrandr
        libxi
        libxext
        libxfixes
      ];

    extraInstallCommands = ''
      install -Dm644 ${./99-vial.rules} $out/lib/udev/rules.d/99-vial.rules
      install -Dm644 ${./pipette.desktop} $out/share/applications/pipette.desktop
      install -Dm644 ${./icon.png} $out/share/icons/hicolor/1024x1024/apps/pipette.png
    '';

    meta = {
      description = "Vial-compatible keyboard configurator";
      homepage = "https://github.com/darakuneko/pipette-desktop";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
      mainProgram = "pipette";
    };
  };
in
app.overrideAttrs (old: {
  buildCommand = old.buildCommand + ''
    wrapProgram $out/bin/pipette \
      --unset GIO_EXTRA_MODULES \
      --unset GIO_MODULE_DIR \
      --unset XDG_DATA_DIRS \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
})
