final: prev: {
  sfmono-nerd-font = final.callPackage ./sfmono-nerd-font { };

  advcpmv = final.callPackage ./advcpmv { };

  one-dark-gtk = final.callPackage ./one-dark-gtk { };

  linuwu-sense = final.linuxPackages.callPackage ./linuwu-sense { };

  damx = final.callPackage ./damx { };

  damx-daemon = final.callPackage ./damx/daemon.nix { };

  pipette = final.callPackage (
    {
      appimageTools,
      fetchurl,
      lib,
      makeWrapper,
    }:
    let
      app = appimageTools.wrapType2 rec {
        pname = "pipette";
        version = "0.5.1";
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
  ) { };
}
