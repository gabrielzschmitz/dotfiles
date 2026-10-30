{ ... }:

{
  flake.modules.nixos.nvidia = { lib, pkgs, ... }: {
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

    environment.systemPackages = [
      pkgs.nvtopPackages.nvidia
      pkgs.nvtopPackages.intel
    ];

    # Alternate boot entry for using the discrete GPU as the only X11 device.
    # Limine lists it under every generation, so each rebuild updates it too.
    # The laptop MUX must be set to the discrete GPU (or the panel must be
    # wired to it) for this mode to produce an image.
    specialisation."nvidia-only".configuration = {
      hardware.nvidia.prime = {
        offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };

        intelBusId = lib.mkForce "";
        nvidiaBusId = lib.mkForce "";
      };
    };
  };
}
