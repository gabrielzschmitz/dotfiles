{ ... }:

{
  flake.modules.homeManager.agent-orchestrator =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.agent-orchestrator ];
    };
}
