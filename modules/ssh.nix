{ ... }:

{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;

      enableDefaultConfig = false;

      settings = {
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
