{ inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt;

    packages = {
      advcpmv = pkgs.callPackage ../pkgs/advcpmv { };

      damx = pkgs.callPackage ../pkgs/damx { };

      damx-daemon = pkgs.callPackage ../pkgs/damx/daemon.nix { };

      linuwu-sense = pkgs.linuxPackages.callPackage ../pkgs/linuwu-sense { };
    };

    devShells.damx = pkgs.mkShell {
      packages = [
        pkgs.dotnetCorePackages.sdk_9_0
        pkgs.python3
        pkgs.pkg-config
      ];

      buildInputs = [
        pkgs.libx11
        pkgs.libice
        pkgs.libsm
        pkgs.libxrandr
        pkgs.libxi
        pkgs.libxcursor
        pkgs.libxext
        pkgs.libxcb
        pkgs.fontconfig
        pkgs.freetype
        pkgs.libglvnd
        pkgs.mesa
        pkgs.icu
        pkgs.krb5
        pkgs.libunwind
        pkgs.openssl
        pkgs.zlib
      ];

      DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_9_0}/share/dotnet";
    };

    devShells.linuwu-sense = pkgs.mkShell {
      packages = [
        pkgs.gcc
        pkgs.gnumake
        pkgs.bear
        pkgs.clang-tools
      ];

      nativeBuildInputs = pkgs.linuxPackages.kernel.moduleBuildDependencies;

      KDIR = "${pkgs.linuxPackages.kernel.dev}/lib/modules/${pkgs.linuxPackages.kernel.modDirVersion}/build";
    };
  };
}
