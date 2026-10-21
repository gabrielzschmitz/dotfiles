{ pkgs, ... }:

let
  lyTtyPalette = pkgs.writeShellScript "ly-tty-palette" ''
    # Reset the console, then set its default background and foreground.
    printf '\033c\033]P0282C34\033]P7ABB2BF' > /dev/tty1
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
      bg = 2638900; # #282C34
      fg = 11252415; # #ABB2BF
      border_fg = 6402031; # #61AFEF
      error_bg = 2638900; # #282C34
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
        ${pkgs.xorg.xrdb}/bin/xrdb -merge "$HOME/.config/X11/Xresources"
        ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --primary --mode 1920x1080
        ${pkgs.xwallpaper}/bin/xwallpaper --zoom "$HOME/pic/wall/icelandiclandscape.jpeg"
        ${pkgs.picom}/bin/picom -b --config "$HOME/.config/picom/picom.conf"
        exec ${pkgs.dwm-custom}/bin/dwm 2> "$HOME/.local/state/xsession-errors"
      '';
    }
  ];
  services.displayManager.defaultSession = "none+xsession";
}
