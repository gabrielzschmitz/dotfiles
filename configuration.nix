{ config, pkgs, ... }:

let
  dwm = import ./dwm.nix { inherit pkgs; };
  lyTtyPalette = pkgs.writeShellScript "ly-tty-palette" ''
    # Reset the console, then set its default background and foreground.
    printf '\033c\033]P0282C34\033]P7ABB2BF' > /dev/tty1
  '';
in
{
  # Bootloader
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;

    limine = {
      enable = true;
      maxGenerations = 5;
      resolution = "1920x1080x32";

      style = {
        # Background
        # wallpapers = [ ./wallpapers/limine-onedark.png ];
        wallpapers = [ ];
        backdrop = "282C34";

        # Menu interface
        interface = {
          resolution = "1920x1080";
          branding = "NIXOS";
          brandingColor = "61AFEF";
          helpColor = "ABB2BF";
          helpColorBright = "E5C07B";
          helpHidden = false;
        };

        # Graphical terminal palette
        graphicalTerminal = {
          background = "00282C34";
          foreground = "ABB2BF";
          brightBackground = "282C34";
          brightForeground = "ABB2BF";

          palette = "282C34;E06C75;98C379;E5C07B;61AFEF;C678DD;56B6C2;ABB2BF";
          brightPalette = "5C6370;E06C75;98C379;E5C07B;61AFEF;C678DD;56B6C2;FFFFFF";

          margin = 24;
          marginGradient = 4;
        };
      };
    };
  };

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

  # Make DWM the default graphical session
  services.displayManager.defaultSession = "none+dwm";

  # Shell and configs
  programs.fish.enable = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # QEMU / SPICE
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Printing
  services.printing.enable = true;

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  users.users.gabrielzschmitz = {
    isNormalUser = true;
    description = "gabrielzschmitz";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };

  environment.binsh = "${pkgs.dash}/bin/dash";

  environment.etc."root-nvim-init.lua".source = ./nvim/init.lua;
  system.activationScripts.rootNeovimConfig = {
    text = ''
      mkdir -p /root/.config/nvim
      ln -sfn /etc/root-nvim-init.lua /root/.config/nvim/init.lua
    '';
  };

  # Minimal system-level tools
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
  ];

  system.stateVersion = "26.05";
}
