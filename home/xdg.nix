{ config, ... }:

{
  xdg.enable = true;

  xdg.configFile."user-dirs.dirs".text = ''
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

  home.activation.createXdgDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/doc" "$HOME/down" "$HOME/mus" "$HOME/pic" "$HOME/vid"
  '';
}
