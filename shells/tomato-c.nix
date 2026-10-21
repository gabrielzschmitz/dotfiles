{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gnumake
    pkg-config
    bear
    ncurses
    libnotify
    fish
  ];

  shellHook = ''
    export TOMATO_FISH_CONFIG="$TMPDIR/tomato-c-fish"

    cat > "$TOMATO_FISH_CONFIG" <<'EOF'
    source ${../configs/fish/prompt.fish}

    function fish_prompt
        set_color --bold red
        echo -n '[TOMATO.C] '
        __dotfiles_prompt_mode
        __dotfiles_prompt_body
    end

    set -g fish_key_bindings fish_vi_key_bindings
    EOF

    exec fish --init-command "source '$TOMATO_FISH_CONFIG'"
  '';
}
