{ fluxer, makeWrapper }:

fluxer.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  postFixup = (old.postFixup or "") + ''
    wrapProgram $out/bin/fluxer \
      --set LIBVA_DRIVER_NAME nvidia \
      --set NVD_BACKEND direct \
      --add-flags "--enable-features=VaapiVideoDecoder,VaapiVideoDecodeLinuxGL,PlatformHEVCDecoderSupport --use-gl=angle --use-angle=gl"
  '';
})
