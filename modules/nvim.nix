{ ... }:

{
  flake.modules.nixos.nvim = {
    environment.etc."root-nvim-init.lua".source = ../configs/nvim/init.lua;

    system.activationScripts.rootNeovimConfig = {
      text = ''
        mkdir -p /root/.config/nvim
        ln -sfn /etc/root-nvim-init.lua /root/.config/nvim/init.lua
      '';
    };
  };

  flake.modules.homeManager.nvim =
    { pkgs, ... }:
    {
      home.file.".config/nvim/init.lua".source = ../configs/nvim/init.lua;

      home.file.".config/nvim/.clang-format".source = ../configs/.clang-format;

      home.packages = with pkgs; [
        # Formatters / linters
        nixd
        nixfmt
        clang-tools
        gofumpt
        gotools
        golangci-lint
        ruff
        stylua
        prettier
        shfmt
        vscode-css-languageserver
        vscode-html-languageserver
        vscode-json-languageserver
      ];
    };
}
