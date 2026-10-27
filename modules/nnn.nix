{ ... }:

{
  flake.modules.homeManager.nnn =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;

      baseNnn = (pkgs.nnn.override { withNerdIcons = true; }).overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../pkgs/nnn-fixed-contexts.patch
          ../pkgs/nnn-onedark-icons.patch
          ../pkgs/nnn-onedark-iconlookup.patch
        ];

        # .iconlookup emits an invalid SGR parameter (;10m) for regular files
        # and executables, which makes st print a stream of erresc errors in
        # the preview pane.  Use the intended bold attribute instead.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace plugins/.iconlookup \
            --replace-fail 'ent, "10")' 'ent, "1")'
        '';
      });

      tmuxConf = pkgs.writeText "nnn-tmux.conf" ''
        set-option -g allow-passthrough on
        set-option -g default-terminal "tmux-256color"
        set-option -g escape-time 10
        set-option -g status off
      '';

      # Run nnn inside a private tmux session so preview-tui can use a tmux
      # split in the same st window instead of spawning a second terminal.
      nnnTuiScript = pkgs.writeShellScript "nnn-tmux" ''
        set -euo pipefail

        # Already in tmux, or not attached to a terminal: use nnn directly.
        if [ -n "''${TMUX-}" ] || [ ! -t 0 ] || [ ! -t 1 ]; then
          exec ${baseNnn}/bin/nnn "$@"
        fi

        exec ${pkgs.tmux}/bin/tmux \
          -L nnn \
          -f ${tmuxConf} \
          new-session \
          -s "nnn-$$" \
          -c "$PWD" \
          -e "PATH=''${PATH-}" \
          -e "HOME=''${HOME-}" \
          -e "USER=''${USER-}" \
          -e "SHELL=''${SHELL-}" \
          -e "DISPLAY=''${DISPLAY-}" \
          -e "WAYLAND_DISPLAY=''${WAYLAND_DISPLAY-}" \
          -e "XAUTHORITY=''${XAUTHORITY-}" \
          -e "XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR-}" \
          -e "XDG_CONFIG_HOME=''${XDG_CONFIG_HOME-}" \
          -e "XDG_CACHE_HOME=''${XDG_CACHE_HOME-}" \
          -e "DBUS_SESSION_BUS_ADDRESS=''${DBUS_SESSION_BUS_ADDRESS-}" \
          -e "SSH_AUTH_SOCK=''${SSH_AUTH_SOCK-}" \
          -e "COLORTERM=''${COLORTERM-}" \
          -e "LANG=''${LANG-}" \
          -e "LC_ALL=''${LC_ALL-}" \
          -e "NNN_TMPFILE=''${NNN_TMPFILE-}" \
          -e "NNN_FCOLORS=''${NNN_FCOLORS-}" \
          -e "NNN_COLORS=''${NNN_COLORS-}" \
          -e "NNN_BMS=''${NNN_BMS-}" \
          -e "NNN_PLUG=''${NNN_PLUG-}" \
          -e "NNN_CTX6=''${NNN_CTX6-}" \
          -e "NNN_CTX7=''${NNN_CTX7-}" \
          -e "NNN_CTX8=''${NNN_CTX8-}" \
          -e "NNN_PREVIEWDIR=''${NNN_PREVIEWDIR-}" \
          -e "NNN_PREVIEWIMGPROG=''${NNN_PREVIEWIMGPROG-}" \
          -e "NNN_PREVIEWVIDEO=''${NNN_PREVIEWVIDEO-}" \
          -e "NNN_ICONLOOKUP=''${NNN_ICONLOOKUP-}" \
          -e "NNN_BATTHEME=''${NNN_BATTHEME-}" \
          -e "NNN_BATSTYLE=''${NNN_BATSTYLE-}" \
          -e "BAT_THEME=''${BAT_THEME-}" \
          -e "BAT_STYLE=''${BAT_STYLE-}" \
          -- ${baseNnn}/bin/nnn "$@"
      '';

      nnnPackage = pkgs.stdenv.mkDerivation {
        pname = "nnn-tmux";
        version = baseNnn.version;

        dontUnpack = true;
        dontBuild = true;

        installPhase = ''
          mkdir -p $out/bin
          ln -s ${baseNnn}/share $out/share
          cp ${nnnTuiScript} $out/bin/nnn
          chmod +x $out/bin/nnn

          runHook postInstall
        '';
      };

      bookmarks = {
        "6" = home;
        "7" = "${home}/.local/src";
        "8" = "${home}/.dotfiles";

        d = "${home}/doc";
        D = "${home}/down";
        p = "${home}/pic";
        v = "${home}/vid";
        m = "${home}/mus";
        c = "${home}/.config";
      };

      # Home Manager's nnn module passes these through makeWrapper's
      # `--prefix ... :`, which splits the value at every colon.  nnn's own
      # syntax uses colons between key and path/plugin, so set the variables
      # directly instead of using the module's bookmarks/mappings options.
      nnnBms = lib.concatStringsSep ";" (lib.mapAttrsToList (key: value: "${key}:${value}") bookmarks);
      nnnPlug = "p:preview-tui;d:dragdrop;i:imgview;c:fzcd;o:fzopen;g:gitroot;E:suedit;s:stats";
    in
    {
      programs.nnn = {
        enable = true;
        package = nnnPackage;

        # `n` becomes the cd-on-quit wrapper; `fm` is the plain nnn alias.
        quitcd = true;
        enableFishIntegration = true;

        plugins.src = "${baseNnn}/share/plugins";

        options = {
          a = true; # auto-managed FIFO, needed by preview-tui
          d = true; # detail mode
          e = true; # open text files in $VISUAL
          f = true; # history file
          H = true; # show hidden files
          r = true; # cpg/mvg progress bars
          x = true; # cp/mv/rm notifications + clipboard + xterm title
          B = true; # bsdtar for archives
          P = "p"; # start preview-tui automatically
        };

        extraPackages = with pkgs; [
          advcpmv
          atool
          bat
          chafa
          dragon-drop
          fd
          ffmpeg
          ffmpegthumbnailer
          fzf
          imagemagick
          jq
          libarchive
          libnotify
          mediainfo
          mpv
          nsxiv
          poppler-utils
          rsync
          tmux
          tree
          xclip
          xdg-utils
          zathura
        ];
      };

      home.sessionVariables = {
        # OneDark ANSI palette (the st/Xresources colors are OneDark).
        NNN_FCOLORS = "0b0b0c0a000d0e0809030d09";
        NNN_COLORS = "42356174";

        NNN_BMS = nnnBms;
        NNN_PLUG = nnnPlug;

        # Fixed context roots for bare 6 / 7 / 8.
        NNN_CTX6 = home;
        NNN_CTX7 = "${home}/.local/src";
        NNN_CTX8 = "${home}/.dotfiles";

        # preview-tui uses a tmux split inside nnn's st window.
        # Disable chafa's terminal capability probe: tmux/st never answers it,
        # so every image/PDF preview would otherwise wait for a 5s timeout.
        NNN_PREVIEWIMGPROG = "chafa --format=kitty --passthrough=tmux --animate=off --probe=off --";
        # kitty graphics from mpv can't be wrapped for tmux passthrough, so
        # use mpv's true-color terminal output for video inside the split.
        NNN_PREVIEWVIDEO = "tct";
        NNN_PREVIEWDIR = "${config.xdg.cacheHome}/nnn/previews";
        NNN_ICONLOOKUP = "1";

        # Keep bat/pager output in the terminal's OneDark ANSI palette.
        NNN_BATTHEME = "ansi";
        NNN_BATSTYLE = "numbers,header,changes";
        BAT_THEME = "ansi";
        BAT_STYLE = "numbers,header,changes";
      };

      programs.fish.shellAliases = {
        fm = "nnn -ex";
        N = "sudo -E nnn -dH";
      };
    };
}
