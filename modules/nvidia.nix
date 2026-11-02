{ ... }:

{
  flake.modules.nixos.nvidia = { lib, pkgs, ... }: {
    hardware.graphics.enable = true;

    hardware.nvidia = {
      # Open kernel modules are required for Blackwell GPUs (RTX 50 series).
      open = true;

      modesetting.enable = true;
      nvidiaSettings = true;

      # Use the discrete GPU as the only X11 device. The laptop MUX must be
      # set to the discrete GPU (or the panel must be wired to it) for this
      # mode to produce an image.
      prime = {
        sync.enable = true;

        # IMPORTANT: Keep the actual GPU bus IDs.
        # Do not clear these!
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = [
      pkgs.nvtopPackages.nvidia
      pkgs.nvtopPackages.intel
    ];

    # Alternate boot entry for keeping the desktop on the Intel iGPU and
    # offloading rendering to the discrete GPU on demand. Limine lists it
    # under every generation, so each rebuild updates it too.
    specialisation."nvidia-optimus".configuration = {
      # The NVIDIA module adds the Intel iGPU modesetting device automatically
      # whenever PRIME offload is enabled. Listing "modesetting" here as well
      # creates a duplicate modesetting screen and makes Xorg fail with
      # "modeset(G0): Failed to create pixmap".
      services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

      hardware.nvidia.prime = {
        offload = {
          enable = lib.mkForce true;
          enableOffloadCmd = lib.mkForce true;
        };

        # Disable display sync; rendering is offloaded on demand instead.
        sync.enable = lib.mkForce false;

        # IMPORTANT: Keep the actual GPU bus IDs.
        # Do not clear these!
        intelBusId = lib.mkForce "PCI:0@0:2:0";
        nvidiaBusId = lib.mkForce "PCI:1@0:0:0";
      };

      # In PRIME-offload mode the internal panel stays on the Intel iGPU and
      # the external port is driven through reverse PRIME, so X exposes it
      # under different output names than in the default discrete-GPU mode.
      my.display = {
        framebuffer = lib.mkForce null;

        outputs = lib.mkForce [
          {
            name = "HDMI-1-0";
            mode = "1920x1080";
            rate = "239.96";
            rotation = "inverted";
            position = "0x0";
            primary = true;
          }
          {
            name = "eDP-1";
            mode = "2560x1600";
            rate = "240";
            rotation = "normal";
            position = "1920x0";
            scale = "0.675x0.675";
          }
        ];
      };
    };
  };
}
