{ ... }:

{
  flake.modules.nixos.nvidia = {
    hardware.graphics.enable = true;

    hardware.nvidia = {
      # Open kernel modules are required for Blackwell GPUs (RTX 50 series).
      open = true;

      modesetting.enable = true;
      nvidiaSettings = true;

      # Keep the desktop on the Intel iGPU and offload rendering to the
      # discrete GPU on demand. Verify the bus IDs on the machine with:
      #   lspci -nn | grep -E 'VGA|3D'
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
