{ config, pkgs, ... }:

{
  # GPG
  programs.gpg = {
    enable = true;

    homedir = "${config.xdg.dataHome}/gnupg";

    settings = {
      use-agent = true;
    };

    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;

    pinentry.package = pkgs.pinentry-gnome3;

    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    enableSshSupport = true;
  };

  # Ensure the relocated keyring directory has strict permissions.
  home.activation.fixGpgHomedirPerms = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${config.xdg.dataHome}/gnupg" ]; then
      chmod 700 "${config.xdg.dataHome}/gnupg"
    fi
  '';
}
