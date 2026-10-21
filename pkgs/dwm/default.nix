{ dwm }:

dwm.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    cp ${./config.h} config.h
  '';
})
