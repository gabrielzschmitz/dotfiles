{ ... }:

{
  flake.modules.homeManager.formatters =
    { pkgs, ... }:
    {
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
