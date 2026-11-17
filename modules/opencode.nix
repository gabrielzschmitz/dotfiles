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

          # Extra instructions: repo rules, CONTRIBUTE.md auto-load, formatter/toolchain detection.
          instructions = [
            "~/.config/opencode/AGENTS.project.md"
            "CONTRIBUTE.md"
            "CONTRIBUTING.md"
            "docs/CONTRIBUTING.md"
          ];

          experimental.todo = true;

          # Local Ollama: fast (gemma4:12b) + quality (qwen3.5:9b thinking)
          model = "ollama/gemma4:12b";
          providers = {
            ollama = {
              settings = {
                baseURL = "http://127.0.0.1:11434/v1";
              };
              models = {
                # Context length is server-side (OLLAMA_CONTEXT_LENGTH in
                # modules/ollama.nix). The OpenAI-compatible endpoint ignores
                # num_ctx, so it must not live in model settings.
                "gemma4:12b" = {
                  name = "Gemma 4 12B (fast)";
                  capabilities.tools = true;
                  body.temperature = 0.2;
                };
                "qwen3.5:9b" = {
                  name = "Qwen 3.5 9B (quality, thinking)";
                  capabilities.tools = true;
                  body.temperature = 0.2;
                };
              };
            };
          };

          agents = {
            build.color = "#7fa4ed";
            plan.color = "#8677cf";

            compliance = {
              description = "One-file CONTRIBUTE.md compliance pass";
              mode = "primary";
              hidden = true;
              steps = 40;
              system = ''
                You are a file-compliance agent. Every action must be a tool call.
                Never write a tool name, path, or shell command as prose.
                Read the repository guidelines first when present.
                Edit only the assigned file. Run only the formatter the repo declares.
                When the repository declares shell.nix, default.nix, flake.nix,
                devbox.json, or mise, run formatter and build commands through that
                environment. Detect it once. Fall back to host tools on failure and
                report which path was used.
                Verify with git diff. Report the file, changes, and open issues. Then stop.
              '';
              permissions = [
                {
                  action = "read";
                  resource = "*";
                  effect = "allow";
                }
                {
                  action = "edit";
                  resource = "*";
                  effect = "allow";
                }
                {
                  action = "shell";
                  resource = "*";
                  effect = "allow";
                }
                {
                  action = "glob";
                  resource = "*";
                  effect = "allow";
                }
                {
                  action = "grep";
                  resource = "*";
                  effect = "allow";
                }
                {
                  action = "question";
                  resource = "*";
                  effect = "allow";
                }
              ];
            };
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

        # Repo rules: CONTRIBUTE.md detection + formatter/toolchain selection
        "opencode/AGENTS.project.md".source = ../configs/opencode/AGENTS.project.md;

        # Caveman default mode
        "caveman/config.json".text = builtins.toJSON {
          defaultMode = "caveman";
        };
      };
    };
}
