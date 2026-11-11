{ ... }:

{
  flake.modules.homeManager.aria2 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      sessionDir = "${config.xdg.stateHome}/aria2";
      sessionFile = "${sessionDir}/aria2.session";
    in
    {
      home.packages = [
        pkgs.ariang
      ];

      # Launch AriaNG with the local aria2 RPC connection configured.
      home.file.".local/bin/ariang" = {
        executable = true;
        text = ''
          #!${pkgs.runtimeShell}
          exec ${pkgs.xdg-utils}/bin/xdg-open \
            "file://${pkgs.ariang}/share/ariang/index.html#!/settings/rpc/set/ws/127.0.0.1/6800/jsonrpc"
        '';
      };
      xdg.desktopEntries.ariang = {
        name = "AriaNG";
        genericName = "Aria2 Download Manager";
        comment = "Manage aria2 downloads";
        icon = "ariang";
        categories = [ "Network" ];
        terminal = false;
        exec = "${config.home.homeDirectory}/.local/bin/ariang";
      };

      # Ensure the session directory and file exist before aria2 starts.
      home.activation.aria2Session = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${sessionDir}"
        $DRY_RUN_CMD touch "${sessionFile}"
      '';

      programs.aria2 = {
        enable = true;
        systemd.enable = true;

        settings = {
          # XDG download directory
          dir = config.xdg.userDirs.download;

          # RPC
          enable-rpc = true;
          rpc-listen-all = false;
          rpc-listen-port = 6800;
          rpc-allow-origin-all = true;

          # Download settings
          continue = true;
          file-allocation = "none";
          max-concurrent-downloads = 5;
          split = 16;
          min-split-size = "1M";

          # Session persistence
          input-file = sessionFile;
          save-session = sessionFile;
          save-session-interval = 30;
          auto-save-interval = 30;

          # BitTorrent
          bt-save-metadata = true;
        };
      };
    };
}
