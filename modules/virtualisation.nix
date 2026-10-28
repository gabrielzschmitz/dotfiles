{ ... }:

{
  flake.modules.nixos.virtualisation = {
    # QEMU / SPICE
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    # Docker
    virtualisation.docker.enable = true;
  };
}
