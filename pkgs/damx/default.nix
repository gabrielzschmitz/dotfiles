{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  makeDesktopItem,
  pciutils,
  mesa-demos,
  lm_sensors,
  dmidecode,
  lsb-release,
  xdg-utils,
  libx11,
  libice,
  libsm,
  libxrandr,
  libxi,
  libxcursor,
  libxext,
  libxcb,
  fontconfig,
  freetype,
  libglvnd,
  mesa,
  source ? ./src,
}:

let
  desktopItem = makeDesktopItem {
    name = "damx";
    exec = "damx";
    icon = "damx";
    desktopName = "DAMX";
    comment = "Div Acer Manager Max";
    categories = [ "System" ];
    keywords = [
      "acer"
      "laptop"
      "system"
    ];
  };
in
buildDotnetModule {
  pname = "damx";
  version = "1.0.2-h1";

  src = source;

  projectFile = "DivAcerManagerMax/DivAcerManagerMax.csproj";
  executables = [ "DivAcerManagerMax" ];

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  runtimeDeps = [
    libx11
    libice
    libsm
    libxrandr
    libxi
    libxcursor
    libxext
    libxcb
    fontconfig
    freetype
    libglvnd
    mesa
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      pciutils
      mesa-demos
      lm_sensors
      dmidecode
      lsb-release
      xdg-utils
    ]}"
  ];

  postInstall = ''
    mkdir -p "$out/bin"
    ln -s DivAcerManagerMax "$out/bin/damx"

    install -Dm644 ${source}/DivAcerManagerMax/icon.png \
      "$out/share/icons/hicolor/256x256/apps/damx.png"

    install -Dm644 ${desktopItem}/share/applications/damx.desktop \
      "$out/share/applications/damx.desktop"
  '';

  meta = {
    description = "Div Acer Manager Max GUI for Acer laptops";
    homepage = "https://github.com/PXDiv/Div-Acer-Manager-Max";
    license = lib.licenses.gpl3Only;
    mainProgram = "damx";
    platforms = lib.platforms.linux;
  };
}
