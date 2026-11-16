{ ... }:

{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    let
      btopWrapped =
        pkgs.runCommand "btop" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.btop}/bin/btop $out/bin/btop \
            --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
        '';
    in
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
        fd
        fzf
        jq
        btopWrapped
        tree-sitter
        doxygen
        lazygit
        pv
        sloc
      ];

      xdg.configFile."btop/btop.conf".source = ../configs/btop/btop.conf;
    };
}
