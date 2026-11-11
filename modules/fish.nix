{ config, ... }:

{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    { pkgs, ... }:
    let
      nixShellFish = pkgs.writeShellScript "nix-shell-fish" ''
        if [ "''${1-}" = "--rcfile" ] && [ -n "''${2-}" ]; then
          rcfile="$2"
          exec ${pkgs.bashInteractive}/bin/bash --noprofile --norc -c '
            source "$1"
            export SHELL=${pkgs.fish}/bin/fish
            exec ${pkgs.fish}/bin/fish
          ' nix-shell "$rcfile"
        fi
        exec ${pkgs.bashInteractive}/bin/bash "$@"
      '';
      flakeDir = "/home/gabrielzschmitz/.dotfiles";

      # Resolve the hostname when an alias runs, not when Home Manager builds
      # this configuration, so the target always follows the running system.
      flake = "${flakeDir}#(uname -n)";
    in
    {
      home.packages = [
        pkgs.nix-output-monitor
      ];

      home.sessionVariables.NIX_BUILD_SHELL = "${nixShellFish}";

      # Match fzf to the One Dark palette in configs/Xresources.
      home.sessionVariables.FZF_DEFAULT_OPTS =
        "--color="
        + builtins.concatStringsSep "," [
          "fg:#abb2bf"
          "bg:#14171c"
          "hl:#61afef"
          "fg+:#abb2bf"
          "bg+:#282c34"
          "hl+:#61afef"
          "info:#56b6c2"
          "prompt:#61afef"
          "pointer:#61afef"
          "marker:#98c379"
          "spinner:#56b6c2"
          "header:#d19a66"
          "border:#5c6370"
          "gutter:#14171c"
          "query:#abb2bf"
          "label:#abb2bf"
          "scrollbar:#5c6370"
          "separator:#5c6370"
        ];

      # Home Manager exports this guard from the shell that started the
      # graphical session.  Child shells then skip the current generation's
      # session variables and keep stale values after a rebuild.  Clear it
      # before config.fish sources hm-session-vars.fish.
      xdg.configFile."fish/conf.d/00-hm-session-vars.fish".text = ''
        set -e __HM_SESS_VARS_SOURCED
      '';

      # Fish
      programs.fish = {
        enable = true;

        plugins = [
          {
            name = "bass";
            src = pkgs.fetchFromGitHub {
              owner = "edc";
              repo = "bass";
              rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
              hash = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
            };
          }
        ];

        shellAliases = {
          ll = "ls -lah";
          ".." = "cd ..";

          rebuild = "sudo -v; and nix-monitor sudo nixos-rebuild build --flake ${flake}";

          reswitch = "sudo -v; and nix-monitor sudo nixos-rebuild switch --flake ${flake}";

          reupdate = ''
            nix flake update --flake ${flakeDir}; and
            sudo -v; and
            nix-monitor sudo nixos-rebuild switch --flake ${flake}
          '';

          reclean = ''
            sudo -v; and
            nix-monitor sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1; and
            nix-monitor sudo nix-collect-garbage -d; and
            nix-monitor sudo nixos-rebuild switch --flake ${flake}
          '';
        };

        interactiveShellInit = /* bash */ ''
          set -gx NIX_BUILD_SHELL ${nixShellFish}

          if command -q gpgconf
            set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
          end
          set -gx GPG_TTY (tty)
          if command -q gpg-connect-agent
            gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
          end

          set -gx TERMINAL st
          set -gx EDITOR nvim
          set -gx VISUAL nvim
          set -gx MPD_HOST "$HOME/.config/mpd/socket"
          fish_add_path "$HOME/.local/bin"

          source ${../configs/fish/prompt.fish}

          set -g fish_key_bindings fish_vi_key_bindings
          set -g fish_cursor_default block
          set -g fish_cursor_insert line
          set -g fish_cursor_replace_one underscore
          set -g fish_cursor_visual block

          # Do not pass Home Manager's session-vars guard to graphical apps.
          set -e __HM_SESS_VARS_SOURCED
        '';

        functions = {
          fish_greeting = ''
            fastfetch
          '';

          emsdk = ''
            bass source /usr/lib/emsdk/emsdk_env.sh ';'
          '';

          fish_title = ''
            if set -q SPTERM
                echo "Scratchpad Term"
            else
                echo (prompt_pwd)
            end
          '';

          nixpkgs-unstable = ''
            if test (count $argv) -ne 1
              echo "Usage: nixpkgs-unstable <package>"
              return 1
            end

            set -l flake "github:NixOS/nixpkgs/nixos-unstable"

            # Resolve package position from the latest upstream revision.
            set -l pkg_position (nix eval --refresh --impure --raw --expr "
                (builtins.getFlake \"$flake\").legacyPackages.x86_64-linux.$argv[1].meta.position
                " 2>/dev/null | string split ':' -f 1)

            if test -z "$pkg_position"
              echo "Package '$argv[1]' not found or has no source position."
              return 1
            end

            # Extract the path relative to the Nixpkgs repository.
            set -l relative_path (string replace -r '^.*/(pkgs/.*)$' '$1' "$pkg_position")

            if not string match -rq '^pkgs/' "$relative_path"
              echo "Could not resolve upstream package path: $pkg_position"
              return 1
            end

            # Get the exact revision used by the refreshed flake.
            set -l revision (nix eval --impure --raw --expr "
              (builtins.getFlake \"$flake\").sourceInfo.rev
            " 2>/dev/null)

            if test -z "$revision"
              echo "Could not resolve upstream revision."
              return 1
            end

            set -l url "https://raw.githubusercontent.com/NixOS/nixpkgs/$revision/$relative_path"
            set -l tmp_file (mktemp) || return 1

            # Always fetch directly from GitHub.
            if not curl -fsSL -H "Cache-Control: no-cache" "$url" -o "$tmp_file"
              echo "Failed to fetch upstream source."
              rm -f "$tmp_file"
              return 1
            end

            # Display source and preserve bat's exit status.
            bat --language=nix "$tmp_file"
            set -l exit_status $status

            # Remove temporary file.
            rm -f "$tmp_file"

            return $exit_status
          '';

          # Use nom for Nix commands that support structured build monitoring.
          nix = ''
            if test (count $argv) -eq 0
              command nix
              return $status
            end

            switch $argv[1]
              case build shell develop copy flake
                command nom $argv
              case '*'
                command nix $argv
            end
          '';

          # Monitor commands that do not have a dedicated nom subcommand,
          # such as nixos-rebuild, nix-env and nix-collect-garbage.
          nix-monitor = ''
            command $argv |& command nom
            set -l command_status $pipestatus[1]
            return $command_status
          '';
        };
      };
    };
}
