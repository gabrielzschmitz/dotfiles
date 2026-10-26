{ ... }:

{
  flake.modules.nixos.damx =
    { config, pkgs, ... }:
    {
      boot.extraModulePackages = [
        (config.boot.kernelPackages.callPackage ../pkgs/linuwu-sense { })
      ];

      boot.kernelModules = [ "linuwu_sense" ];
      boot.blacklistedKernelModules = [ "acer_wmi" ];

      environment.systemPackages = [
        pkgs.damx
        pkgs.damx-daemon
      ];

      systemd.services.damx-daemon = {
        description = "DAMX daemon for Acer laptop controls";

        # The daemon talks to linuwu_sense, so the module has to be loaded first.
        after = [ "systemd-modules-load.service" ];
        requires = [ "systemd-modules-load.service" ];

        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.sudo
          pkgs.kmod
          pkgs.systemd
          pkgs.upower
          pkgs.acpi
        ];

        environment.PYTHONUNBUFFERED = "1";

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.damx-daemon}/bin/damx-daemon";
          Restart = "on-failure";
          RestartSec = 5;
          User = "root";
          Group = "root";
        };
      };
    };
}
