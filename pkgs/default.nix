{ inputs }:
final: prev: {
  sfmono-nerd-font = final.callPackage ./sfmono-nerd-font { };

  advcpmv = final.callPackage ./advcpmv { };

  one-dark-gtk = final.callPackage ./one-dark-gtk { };

  linuwu-sense = final.linuxPackages.callPackage ./linuwu-sense { };

  damx = final.callPackage ./damx { };

  damx-daemon = final.callPackage ./damx/daemon.nix { };

  fluxer = final.callPackage ./fluxer {
    fluxer = inputs.fluxer.packages.${final.stdenv.hostPlatform.system}.fluxer;
  };

  pipette = final.callPackage ./pipette { };
}
