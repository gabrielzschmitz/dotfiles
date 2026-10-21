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
  ];
}
