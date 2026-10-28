{ ... }:

{
  flake.modules.homeManager.music =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        rmpc
        cava
        mpc
        mpd
        mpd-mpris
      ];

      xdg.configFile = {
        "mpd/mpd.conf".source = ../configs/music/mpd.conf;
        "rmpc/config.ron".source = ../configs/music/rmpc.ron;
      };

      home.activation.createMpdDirectories = ''
        $DRY_RUN_CMD mkdir -p \
          "$HOME/.config/mpd/playlists"
      '';
    };
}
