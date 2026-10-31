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

    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];

    environment.systemPackages = [
      pkgs.nvtopPackages.nvidia
      pkgs.nvtopPackages.intel
    ];

    # Alternate boot entry for using the discrete GPU as the only X11 device.
    # Limine lists it under every generation, so each rebuild updates it too.
    # The laptop MUX must be set to the discrete GPU (or the panel must be
    # wired to it) for this mode to produce an image.
    specialisation."nvidia-only".configuration = {
      services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

      hardware.nvidia.prime = {
        # Disable render offloading.
        offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };

        # Use NVIDIA for all rendering, Intel for display output.
        sync.enable = lib.mkForce true;

        # IMPORTANT: Keep the actual GPU bus IDs.
        # Do not clear these!
        intelBusId = lib.mkForce "PCI:0@0:2:0";
        nvidiaBusId = lib.mkForce "PCI:1@0:0:0";
      };

      my.display.outputs = lib.mkForce [
        {
          name = "HDMI-0";
          mode = "1920x1080";
          rate = "239.96";
          rotation = "inverted";
          position = "0x0";
          primary = true;
        }
        {
          name = "eDP-1-1";
          mode = "2560x1600";
          rate = "240";
          rotation = "normal";
          position = "1920x0";
          scale = "0.675x0.675";
        }
      ];
    };
  };
}
