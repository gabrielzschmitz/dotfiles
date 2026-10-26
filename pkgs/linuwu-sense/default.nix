{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  source ? ./src,
}:

stdenv.mkDerivation {
  pname = "linuwu-sense";
  version = "25.701-${kernel.version}";

  src = source;

  hardeningDisable = [ "pic" ];
  dontStrip = true;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 src/linuwu_sense.ko \
      "$out/lib/modules/${kernel.modDirVersion}/extra/linuwu_sense.ko"

    runHook postInstall
  '';

  meta = {
    description = "Linux kernel module for Acer WMI controls, with PHN16S-71 support";
    homepage = "https://github.com/PXDiv/Div-Linuwu-Sense";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
