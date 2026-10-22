{ ... }:

let
  username = "gabrielzschmitz";
  homeDirectory = "/home/${username}";
in
{
  flake.modules.nixos.user =
    { pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        description = username;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.fish;
      };
    };

  flake.modules.homeManager.user = {
    home.username = username;
    home.homeDirectory = homeDirectory;

    home.stateVersion = "26.05";

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";

      # Go
      GOPATH = "$HOME/.local/share/go";
      GOBIN = "$HOME/.local/bin";

      # npm
      npm_config_cache = "$HOME/.cache/npm";
      NPM_CONFIG_CACHE = "$HOME/.cache/npm";

      # Yarn
      YARN_CACHE_FOLDER = "$HOME/.cache/yarn";
      YARN_GLOBAL_FOLDER = "$HOME/.local/share/yarn";

      # X11 auth
      XAUTHORITY = "$HOME/.local/state/xauth/xauthority";
      ICEAUTHORITY = "$HOME/.cache/ICEauthority";

      # X11 compose
      XCOMPOSEFILE = "$HOME/.config/X11/xcompose";
      XCOMPOSECACHE = "$HOME/.cache/X11/xcompose";
    };

    # Home Manager
    programs.home-manager.enable = true;
  };
}
