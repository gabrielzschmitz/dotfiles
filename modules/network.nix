{ ... }:

{
  flake.modules.nixos.network =
    { pkgs, ... }:
    {
      networking.networkmanager.enable = true;

      environment.systemPackages = with pkgs; [
        networkmanager
        networkmanagerapplet
        networkmanager_dmenu
        iw
        wirelesstools
        util-linux # provides rfkill and more
        ethtool
        nmap
      ];

      programs.nm-applet.enable = true;
    };
}
