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
  };

  # Home Manager
  programs.home-manager.enable = true;
}
