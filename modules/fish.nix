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
      host = "nixos";
      flake = "${flakeDir}#${host}";
    in
    {
      home.sessionVariables.NIX_BUILD_SHELL = "${nixShellFish}";

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

          rebuild = "sudo nixos-rebuild build --flake ${flake}";
          reswitch = "sudo nixos-rebuild switch --flake ${flake}";
          reupdate = "nix flake update --flake ${flakeDir} && sudo nixos-rebuild switch --flake ${flake}";
          reclean = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1 && sudo nix-collect-garbage -d";
        };

        interactiveShellInit = ''
          set -gx NIX_BUILD_SHELL ${nixShellFish}

          if command -q gpgconf
            set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
          end
          set -gx GPG_TTY (tty)
          if command -q gpg-connect-agent
            gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
          end

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
        '';

        functions = {
          fish_greeting = ''
            fastfetch
          '';

          emsdk = ''
            bass source /usr/lib/emsdk/emsdk_env.sh ';'
          '';
        };
      };
    };
}
