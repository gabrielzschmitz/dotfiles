{ ... }:

{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;

      enableDefaultConfig = false;

      settings = {
        "*" = {
          ServerAliveInterval = 30;
          ServerAliveCountMax = 3;
          TCPKeepAlive = true;
        };

        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/github_ed25519";
          IdentitiesOnly = true;
        };
      };
    };
  };
}
