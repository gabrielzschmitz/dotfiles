{
  lib,
  stdenv,
  makeWrapper,
  python3,
  sudo,
  kmod,
  systemd,
  upower,
  acpi,
  source ? ./src,
}:

stdenv.mkDerivation {
  pname = "damx-daemon";
  version = "0.5.2";

  src = source;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${source}/DAMM-Daemon/DAMX-Daemon.py \
      "$out/libexec/damx/DAMX-Daemon.py"
    install -Dm644 ${source}/DAMM-Daemon/PowerSourceDetection.py \
      "$out/libexec/damx/PowerSourceDetection.py"
    install -Dm644 ${source}/DAMM-Daemon/KeyboardMonitor.py \
      "$out/libexec/damx/KeyboardMonitor.py"

    makeWrapper ${python3}/bin/python3 "$out/bin/damx-daemon" \
      --add-flags "$out/libexec/damx/DAMX-Daemon.py" \
      --prefix PATH : "${
        lib.makeBinPath [
          sudo
          kmod
          systemd
          upower
          acpi
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "DAMX root daemon for Acer laptop controls";
    homepage = "https://github.com/PXDiv/Div-Acer-Manager-Max";
    license = lib.licenses.gpl3Only;
    mainProgram = "damx-daemon";
    platforms = lib.platforms.linux;
  };
}
