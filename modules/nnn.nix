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

      nnnPackage = (pkgs.nnn.override { withNerdIcons = true; }).overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../pkgs/nnn-fixed-contexts.patch ];
      });

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

        plugins.src = "${nnnPackage}/share/plugins";

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

        # preview-tui: st is the second tiled pane and supports kitty graphics.
        NNN_TERMINAL = "st";
        NNN_PREVIEWIMGPROG = "chafa --format=kitty --animate=off --";
        NNN_PREVIEWVIDEO = "kitty";
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
