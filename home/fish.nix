{ pkgs, ... }:

{
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
      rebuild = "sudo nixos-rebuild build --flake '#nixos'";
      reswitch = "sudo nixos-rebuild switch --flake '#nixos'";
      reclean = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1 && sudo nix-collect-garbage -d";
    };

    interactiveShellInit = ''
      if test -z "$SSH_AUTH_SOCK"; and test -S "/run/user/"(id -u)"/ssh-agent"
        set -gx SSH_AUTH_SOCK "/run/user/"(id -u)"/ssh-agent"
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
}
