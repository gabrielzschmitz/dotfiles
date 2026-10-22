{ ... }:

{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Development
        neovim
        go
        python3
        nodejs
        yarn
        gcc
        gnumake
        bear
        git
        gnupg
        pinentry-gnome3
        fd
        fzf
        jq
        btop
        tree-sitter
        lazygit

        # AI
        opencode
      ];
    };
}
