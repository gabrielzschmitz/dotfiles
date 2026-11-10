{
  fluxer,
  lib,
  libdbusmenu,
  libdbusmenu-gtk3,
  makeWrapper,
}:

fluxer.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
  buildInputs = (old.buildInputs or [ ]) ++ [
    libdbusmenu
    libdbusmenu-gtk3
  ];

  postFixup = (old.postFixup or "") + ''
    wrapProgram $out/bin/fluxer \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libdbusmenu
          libdbusmenu-gtk3
        ]
      } \
      --set LIBVA_DRIVER_NAME nvidia \
      --set NVD_BACKEND direct \
      --add-flags "--enable-features=VaapiVideoDecoder,VaapiVideoDecodeLinuxGL,PlatformHEVCDecoderSupport --use-gl=angle --use-angle=gl"
  '';
})
