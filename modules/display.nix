{ ... }:

{
  flake.modules.nixos.display =
    { pkgs, ... }:
    let
      lyTtyPalette = pkgs.writeShellScript "ly-tty-palette" ''
        # Reset the console, then set its default background and foreground.
        printf '\033c\033]P014171C\033]P7ABB2BF' > /dev/tty1
      '';
    in
    {
      # X11 and DWM
      services.xserver = {
        enable = true;

        windowManager.dwm = {
          enable = true;
          package = pkgs.dwm-custom;
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
            ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --primary --mode 1920x1080
            ${pkgs.xwallpaper}/bin/xwallpaper --zoom "$HOME/pic/wall/icelandiclandscape.jpeg"

            ${pkgs.dunst}/bin/dunst &
            ${pkgs.picom}/bin/picom -b --config "$HOME/.config/picom/picom.conf" &
            ${pkgs.xset}/bin/xset r rate 300 50 &

            ${pkgs.dwm-custom}/bin/dwm-bar &
            exec ${pkgs.dwm-custom}/bin/dwm 2> "$HOME/.cache/X11/xsession-errors"
          '';
        }
      ];
      services.displayManager.defaultSession = "none+xsession";
    };

  flake.modules.homeManager.display =
    { config, pkgs, ... }:
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
      home.file.".config/picom/picom.conf".source = ../configs/picom/picom.conf;
    };
}
