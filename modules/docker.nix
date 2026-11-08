{ ... }:

{
  flake.modules.homeManager.docker =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
        docker-compose
        lazydocker
        dive
        hadolint
      ];

      home.sessionVariables = {
        DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
      };
    };
}
