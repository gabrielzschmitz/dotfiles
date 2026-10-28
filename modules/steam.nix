{ ... }:

{
  flake.modules.nixos.steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.steam = {
        enable = true;

        extraCompatPackages = [
          pkgs.proton-ge-bin
        ];

        # Steam and its games inherit the PRIME offload variables,
        # so they render on the NVIDIA GPU while the desktop stays on
        # the Intel iGPU. In the NVIDIA-only specialisation, offload
        # is disabled and Steam uses the primary GPU.
        package = pkgs.steam.override {
          extraEnv = lib.optionalAttrs config.hardware.nvidia.prime.offload.enable {
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            __VK_LAYER_NV_optimus = "NVIDIA_only";
          };
        };
      };

      programs.gamemode.enable = true;
    };
}
