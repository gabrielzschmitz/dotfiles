{ lib, ... }:

let
  # One Dark palette shared by Limine and the Linux virtual console.
  palette = [
    "14171C"
    "E06C75"
    "98C379"
    "E5C07B"
    "61AFEF"
    "C678DD"
    "56B6C2"
    "ABB2BF"
    "5C6370"
    "E06C75"
    "98C379"
    "E5C07B"
    "61AFEF"
    "C678DD"
    "56B6C2"
    "FFFFFF"
  ];
in
{
  flake.modules.nixos.boot = {
    # Match the Limine palette on all virtual consoles.
    console.colors = palette;

    # Force the QXL connector used by the guest to 1080p for fbcon and Ly.
    boot.kernelParams = [ "video=Virtual-1:1920x1080@60" ];

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
          backdrop = "14171C";

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
            background = "0014171C";
            foreground = "ABB2BF";
            brightBackground = "14171C";
            brightForeground = "ABB2BF";

            palette = lib.concatStringsSep ";" (lib.take 8 palette);
            brightPalette = lib.concatStringsSep ";" (lib.drop 8 palette);

            margin = 24;
            marginGradient = 4;
          };
        };
      };
    };
  };
}
