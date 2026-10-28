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
    };
}
