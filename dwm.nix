{ pkgs }:

pkgs.dwm.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    cp ${./dwm/config.h} config.h
  '';
})
