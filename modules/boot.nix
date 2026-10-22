{ ... }:

{
  flake.modules.nixos.boot = {
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
          # wallpapers = [ ../../wallpapers/limine-onedark.png ];
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
  };
}
