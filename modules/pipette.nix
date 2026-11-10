{ ... }:

{
  flake.modules.homeManager.pipette = {
    home.file.".config/pipette-desktop/config.json".source = ../configs/pipette.json;
  };
}
