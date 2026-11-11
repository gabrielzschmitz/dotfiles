{ ... }:

{
  flake.modules.homeManager.xdg =
    { config, ... }:
    {
      xdg.enable = true;

      xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        comment = "Edit files in Neovim using st";
        exec = "st -e nvim %F";
        terminal = false;
        type = "Application";
        categories = [
          "Utility"
          "TextEditor"
        ];
        mimeType = [
          "text/plain"
          "text/markdown"
          "application/json"
        ];
      };

      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/plain" = "nvim.desktop";
          "text/markdown" = "nvim.desktop";
          "application/json" = "nvim.desktop";

          "application/pdf" = "org.pwmt.zathura.desktop";
          "image/vnd.djvu" = "org.pwmt.zathura.desktop";
          "image/vnd.djvu+multipage" = "org.pwmt.zathura.desktop";
          "image/*" = "nsxiv.desktop";
          "video/*" = "mpv.desktop";
          "audio/*" = "mpv.desktop";

          "x-scheme-handler/http" = "zen-beta.desktop";
          "x-scheme-handler/https" = "zen-beta.desktop";
          "x-scheme-handler/chrome" = "zen-beta.desktop";
          "text/html" = "zen-beta.desktop";
          "application/x-extension-htm" = "zen-beta.desktop";
          "application/x-extension-html" = "zen-beta.desktop";
          "application/x-extension-shtml" = "zen-beta.desktop";
          "application/xhtml+xml" = "zen-beta.desktop";
          "application/x-extension-xhtml" = "zen-beta.desktop";
          "application/x-extension-xht" = "zen-beta.desktop";
        };
      };

      home.sessionVariables = {
        #  XDG_CONFIG_HOME = "$HOME/.config";
        #  XDG_CACHE_HOME = "$HOME/.cache";
        #  XDG_DATA_HOME = "$HOME/.local/share";
        #  XDG_STATE_HOME = "$HOME/.local/state";
        #  XDG_RUNTIME_DIR = "/run/user/$(id -u)";

        CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nvidia/ComputeCache";
        __GL_SHADER_DISK_CACHE_PATH = "${config.xdg.cacheHome}/nvidia/GLCache";

        XDG_DOCUMENTS_DIR = "$HOME/doc";
        XDG_DOWNLOAD_DIR = "$HOME/down";
        XDG_MUSIC_DIR = "$HOME/mus";
        XDG_PICTURES_DIR = "$HOME/pic";
        XDG_VIDEOS_DIR = "$HOME/vid";
      };

      xdg.userDirs = {
        enable = true;
        download = "${config.home.homeDirectory}/down";
        documents = "${config.home.homeDirectory}/doc";
        music = "${config.home.homeDirectory}/mus";
        pictures = "${config.home.homeDirectory}/pic";
        videos = "${config.home.homeDirectory}/vid";
      };

      xdg.configFile."user-dirs.dirs" = {
        force = true;
        text = ''
          XDG_DESKTOP_DIR=""
          XDG_PROJECTS_DIR=""
          XDG_PUBLICSHARE_DIR=""
          XDG_TEMPLATES_DIR=""
          XDG_DOCUMENTS_DIR="$HOME/doc"
          XDG_DOWNLOAD_DIR="$HOME/down"
          XDG_MUSIC_DIR="$HOME/mus"
          XDG_PICTURES_DIR="$HOME/pic"
          XDG_VIDEOS_DIR="$HOME/vid"
        '';
      };

      home.activation.createXdgDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/doc" "$HOME/down" "$HOME/mus" "$HOME/pic" "$HOME/vid"\
        "${config.xdg.cacheHome}/nvidia/GLCache"\
        "${config.xdg.cacheHome}/nvidia/ComputeCache"
      '';

      home.activation.installScripts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.local/bin"

        for script in ${../scripts}/*; do
          [ -f "$script" ] || continue
          install -m 755 "$script" "$HOME/.local/bin/''${script##*/}"
        done
      '';
    };
}
