{ ... }:

{
  flake.modules.homeManager.services =
    { pkgs, ... }:
    {
      # SPICE clipboard agent
      systemd.user.services.spice-vdagent = {
        Unit = {
          Description = "SPICE guest clipboard agent";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "forking";
          ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -d";
          Restart = "on-failure";
          RestartSec = 2;
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
