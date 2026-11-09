{ inputs, ... }:

let
  caveman = inputs.caveman;
in
{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:

    let
      caveman-opencode = pkgs.runCommand "caveman-opencode" { } ''
        mkdir -p $out

        cp -r ${caveman}/src/plugins/opencode/. $out/

        cp ${caveman}/src/hooks/caveman-config.js \
          $out/caveman-config.cjs

        cp ${caveman}/src/hooks/caveman-parse.js \
          $out/caveman-parse.cjs

        # Fail the build if the OpenCode 2.x plugin layout is incomplete.
        test -f $out/server.js
        test -f $out/plugin.js
        test -f $out/package.json
        test -f $out/caveman-config.cjs
        test -f $out/caveman-parse.cjs
      '';
    in
    {
      programs.opencode = {
        enable = true;

        settings = {
          plugins = [
            "${caveman-opencode}"
          ];

          agents = {
            build.color = "#7fa4ed";
            plan.color = "#8677cf";
          };
        };

        cli = {
          animations = true;

          session = {
            permissions = "prompt";
            verbosity = "medium";
          };

          tabs.mode = "auto";

          terminal = {
            title = true;
            copy = "select";
          };

          attention = {
            notifications = true;
            sound = true;
            volume = 0.2;
          };

          theme = {
            name = "onedark";
            mode = "system";
          };
        };
      };

      xdg.configFile = {
        # Custom OneDark theme
        "opencode/themes/onedark.json".source = ../configs/opencode/themes/onedark.json;

        # Caveman slash commands
        "opencode/commands".source = "${caveman}/src/plugins/opencode/commands";

        # Global Caveman instructions
        "opencode/AGENTS.md".source = "${caveman}/src/rules/caveman-activate.md";

        # Caveman default mode
        "caveman/config.json".text = builtins.toJSON {
          defaultMode = "caveman";
        };
      };
    };
}
