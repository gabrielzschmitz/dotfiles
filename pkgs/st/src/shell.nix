{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "st-dev";

  nativeBuildInputs = with pkgs; [
    pkg-config
    ncurses
    gnumake
    gcc
    bear
    clang-tools
  ];

  buildInputs = with pkgs; [
    fontconfig
    freetype
    harfbuzz
    imlib2
    libX11
    libXext
    libXrender
    libXft
    ncurses
  ];

  shellHook = ''
    export ST_FISH_CONFIG="$TMPDIR/st-fish"

    cat > "$ST_FISH_CONFIG" <<'EOF2'
    source ${builtins.toString ../../../../configs/fish/prompt.fish}

    function fish_prompt
        set_color --bold cyan
        echo -n '[ST] '
        __dotfiles_prompt_mode
        __dotfiles_prompt_body
    end

    set -g fish_key_bindings fish_vi_key_bindings
    EOF2

    echo "[st-dev] Entered development shell for st"
    echo "[st-dev] Run 'bear -- make' to generate compile_commands.json for LSP"
    export PKG_CONFIG_PATH="${pkgs.fontconfig.dev}/lib/pkgconfig:${pkgs.freetype.dev}/lib/pkgconfig:${pkgs.harfbuzz.dev}/lib/pkgconfig:${pkgs.imlib2}/lib/pkgconfig:${pkgs.libX11.dev}/lib/pkgconfig:${pkgs.libXext.dev}/lib/pkgconfig:${pkgs.libXrender.dev}/lib/pkgconfig:${pkgs.libXft.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    exec ${pkgs.fish}/bin/fish --init-command "source '$ST_FISH_CONFIG'"
  '';
}
