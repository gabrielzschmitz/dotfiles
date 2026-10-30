{ inputs, ... }:

{
  flake.modules.nixos.display =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      dwm = inputs.dwm.packages.${pkgs.stdenv.hostPlatform.system}.default;
      lyTtyPalette = pkgs.writeShellScript "ly-tty-palette" ''
        # Reset the console, then set its default background and foreground.
        printf '\033c\033]P014171C\033]P7ABB2BF' > /dev/tty1
      '';

      xrandrArgs = lib.concatMap (
        output:
        [
          "--output"
          output.name
        ]
        ++ lib.optionals (output.mode != null) [
          "--mode"
          output.mode
        ]
        ++ lib.optionals (output.rate != null) [
          "--rate"
          output.rate
        ]
        ++ [
          "--rotate"
          output.rotation
        ]
        ++ lib.optionals (output.position != null) [
          "--pos"
          output.position
        ]
        ++ lib.optionals (output.scale != null) [
          "--scale"
          output.scale
        ]
        ++ lib.optionals output.primary [ "--primary" ]
      ) config.my.display.outputs;

      xrandrPrimary = lib.optionalString (config.my.display.outputs != [ ]) ''
        ${pkgs.xrandr}/bin/xrandr ${lib.escapeShellArgs xrandrArgs}
      '';

      startPicom = lib.optionalString config.my.display.picom.enable ''
        ${pkgs.picom}/bin/picom -b --config "$HOME/.config/picom/picom.conf" &
      '';
    in
    {
      options.my.display = {
        picom.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to start the picom compositor in the X session.";
        };

        picom.backend = lib.mkOption {
          type = lib.types.enum [
            "xrender"
            "glx"
          ];
          default = "xrender";
          description = "Rendering backend used by picom.";
        };

        outputs = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "X RandR output name, such as HDMI-1-0 or eDP-1.";
                };

                mode = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Mode passed to --mode, or null to leave it unchanged.";
                };

                rate = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Refresh rate passed to --rate, or null to leave it unchanged.";
                };

                rotation = lib.mkOption {
                  type = lib.types.enum [
                    "normal"
                    "left"
                    "right"
                    "inverted"
                  ];
                  default = "normal";
                  description = "Rotation passed to --rotate.";
                };

                position = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Absolute position passed to --pos, such as 0x0, or null to let X RandR place the output.";
                };

                scale = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Scale passed to --scale, such as 1.35x1.35, or null to keep the native scale.";
                };

                primary = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether to mark this output as the X RandR primary output.";
                };
              };
            }
          );
          default = [ ];
          description = "X RandR outputs configured, in order, when the X session starts.";
        };
      };

      config = {
        # X11 and DWM
        services.xserver = {
          enable = true;

          windowManager.dwm = {
            enable = true;
            package = dwm;
          };
        };

        # Display manager
        services.displayManager.ly = {
          enable = true;

          settings = {
            # Appearance
            animation = "none";
            hide_borders = true;
            hide_version_string = true;
            hide_key_hints = true;
            text_in_center = true;
            box_title = "LOGIN";

            # Clock
            clock = "%A, %d %B  %H:%M";
            bigclock = "en";
            bigclock_seconds = false;
            bigclock_12hr = false;

            # One Dark interface palette (decimal 0xSSRRGGBB)
            bg = 1318684; # #14171C
            fg = 11252415; # #ABB2BF
            border_fg = 6402031; # #61AFEF
            error_bg = 1318684; # #14171C
            error_fg = 31485045; # Bold #E06C75

            full_color = true;
            blank_box = true;

            # Keyboard and password
            numlock = true;
            clear_password = true;
            asterisk = "*";

            # Reapply the TTY palette when Ly resets the terminal.
            term_reset_cmd = "${lyTtyPalette}";
          };
        };

        # Set the palette before Ly starts.
        systemd.services.display-manager.serviceConfig.ExecStartPre = [
          "${lyTtyPalette}"
        ];

        # Custom X session for Ly
        services.xserver.displayManager.session = [
          {
            manage = "window";
            name = "xsession";
            start = ''
              ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.config/X11/Xresources"
              ${xrandrPrimary}
              ${pkgs.xwallpaper}/bin/xwallpaper --zoom "$HOME/pic/wall/icelandiclandscape.jpeg"

              ${pkgs.dunst}/bin/dunst &
              ${pkgs.networkmanagerapplet}/bin/nm-applet &
              ${pkgs.blueman}/bin/blueman-applet &
              ${pkgs.mpd}/bin/mpd &
              ${pkgs.nextcloud-client}/bin/nextcloud \
                --background \
                --logfile "$HOME/.cache/X11/nextcloud.log" \
                --logflush \
                2>&1 &
              ${startPicom}
              ${pkgs.xset}/bin/xset r rate 300 50 &
              ${pkgs.numlockx}/bin/numlockx &
              ${pkgs.setxkbmap}/bin/setxkbmap -model pc105 -layout us -variant alt-intl -option caps:escape &

              ${dwm}/bin/dwm-bar &
              while ${dwm}/bin/dwm 2>> "$HOME/.cache/X11/xsession-errors"; do
                continue
              done
            '';
          }
        ];
        services.displayManager.defaultSession = "none+xsession";
      };
    };

  flake.modules.homeManager.display =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      picomConfig =
        lib.replaceStrings
          [ ''backend = "xrender";'' ]
          [ ''backend = "${osConfig.my.display.picom.backend}";'' ]
          (builtins.readFile ../configs/picom/picom.conf);
    in
    {
      home.packages = with pkgs; [
        xwallpaper
        xrandr
        xinit
        xrdb
        picom
      ];

      home.activation.createWallDir = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/pic/wall"
      '';

      home.activation.createStateDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.local/state/xauth" "$HOME/.local/state" "$HOME/.cache/X11"
      '';

      home.file.".config/X11/Xresources".source = ../configs/Xresources;
      home.file.".config/picom/picom.conf".text = picomConfig;
    };
}
