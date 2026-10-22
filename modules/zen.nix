{ inputs, ... }:

{
  flake.modules.homeManager.zen = {
    imports = [ inputs.zen-browser.homeModules.beta ];

    programs.zen-browser.enable = true;
  };
}
