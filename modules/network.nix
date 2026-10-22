{ ... }:

{
  flake.modules.nixos.network = {
    networking.networkmanager.enable = true;
  };
}
