{
  imports = [
    ./fastfetch.nix
    ./fish.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./nvim.nix
    ./picom.nix
    ./packages/cli.nix
    ./packages/desktop.nix
    ./packages/dev.nix
    ./packages/formatters.nix
    ./services.nix
    ./ssh.nix
    ./xdg.nix
    ./xsession.nix
  ];

  home.username = "gabrielzschmitz";
  home.homeDirectory = "/home/gabrielzschmitz";

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
  };

  # Home Manager
  programs.home-manager.enable = true;
}
