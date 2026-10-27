final: prev: {
  sfmono-nerd-font = final.callPackage ./sfmono-nerd-font { };
  pinentry-dmenu = final.callPackage ./pinentry-dmenu { };

  linuwu-sense = final.linuxPackages.callPackage ./linuwu-sense { };

  damx = final.callPackage ./damx { };

  damx-daemon = final.callPackage ./damx/daemon.nix { };

  advcpmv = final.callPackage ./advcpmv { };
}
