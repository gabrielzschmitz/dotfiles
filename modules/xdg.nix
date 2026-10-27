{ ... }:

{
  flake.modules.homeManager.xdg =
    { config, ... }:
    {
      xdg.enable = true;

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
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
        mkdir -p "$HOME/doc" "$HOME/down" "$HOME/mus" "$HOME/pic" "$HOME/vid"
      '';
    };
}
