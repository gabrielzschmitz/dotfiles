{ ... }:

{
  flake.modules.homeManager.thunar =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Archive manager and backends
        xarchiver
        zip
        unzip
        gnutar
        gzip
        bzip2
        xz
        p7zip

        # File checksums
        gtkhash

        # Thumbnail generation
        ffmpegthumbnailer
        poppler
        libgsf
      ];

      # Open terminal here
      xdg.configFile."xfce4/helpers.rc".text = ''
        TerminalEmulator=st
      '';
      xdg.configFile."Thunar/accels.scm".text = ''
        (gtk_accel_path "<Actions>/ThunarActions/uca-action-1788831271801904-1" "F4") ; Open Terminal Here
        (gtk_accel_path "<Actions>/ThunarWindow/toggle-split-view" "F3") ; Dual Panel
      '';

      # Bookmarks
      xdg.configFile."gtk-3.0/bookmarks".text = ''
        file:///home/gabrielzschmitz/next
      '';
    };

  flake.modules.nixos.thunar =
    { pkgs, ... }:
    let
      gtkhashThunar = pkgs.gtkhash.overrideAttrs (old: {
        pname = "gtkhash-thunar";

        buildInputs = (old.buildInputs or [ ]) ++ [
          pkgs.thunar-unwrapped
        ];

        mesonFlags = (old.mesonFlags or [ ]) ++ [
          "-Dbuild-gtkhash=false"
          "-Dbuild-thunar=true"
        ];

        postPatch = (old.postPatch or "") + ''
          substituteInPlace meson.build \
            --replace-fail \
              "thunar_extension_dir = thunar.get_pkgconfig_variable('extensionsdir')" \
              "thunar_extension_dir = get_option('prefix') / 'lib/thunarx-3'"
        '';
      });
      thunarArchivePlugin = pkgs.thunar-archive-plugin.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p "$out/libexec/thunar-archive-plugin"

          ln -sf \
            "${pkgs.xarchiver}/libexec/thunar-archive-plugin/xarchiver.tap" \
            "$out/libexec/thunar-archive-plugin/xarchiver.tap"
        '';
      });
    in
    {
      # Install Thunar and integrate its extensions
      programs.thunar = {
        enable = true;

        plugins = [
          pkgs.thunar-media-tags-plugin
          pkgs.thunar-volman
          gtkhashThunar
          thunarArchivePlugin
        ];
      };

      # Archive manager available system-wide
      environment.systemPackages = with pkgs; [
        xarchiver
      ];

      # File operations, trash, removable drives, and remote locations
      services.gvfs.enable = true;

      # File thumbnails
      services.tumbler.enable = true;

      # Persist XFCE application preferences
      programs.xfconf.enable = true;
    };
}
