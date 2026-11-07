{ ... }:

{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Development
        neovim
        go
        valgrind
        python3
        nodejs
        yarn
        gcc
        gnumake
        bear
        git
        github-cli
        gnupg
        pinentry-gnome3
        fd
        fzf
        jq
        btop
        tree-sitter
        doxygen
        lazygit
        pv
        sloc
      ];
    };
}
