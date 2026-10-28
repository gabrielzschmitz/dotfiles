{ ... }:

{
  flake.modules.nixos.bluetooth =
    { pkgs, ... }:
    {
      # Bluetooth service and hardware support
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      services.blueman.enable = true;

      environment.systemPackages = with pkgs; [
        bluez
        bluez-tools
        blueman
      ];
    };
}
