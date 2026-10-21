final: prev: {
  dwm-custom = final.callPackage ./dwm { };
  st = final.callPackage ./st { };
  sfmono-nerd-font = final.callPackage ./sfmono-nerd-font { };
  pinentry-dmenu = final.callPackage ./pinentry-dmenu { };
  dmenu = final.callPackage ./dmenu { };
}
