{ pkgs, ... }:

{
  # GPG
  programs.gpg = {
    enable = true;

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
  };
}
