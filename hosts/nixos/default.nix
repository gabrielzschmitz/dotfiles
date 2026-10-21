{
  imports = [
    ./hardware-configuration.nix
    ../../system
  ];

  networking.hostName = "nixos";

  system.stateVersion = "26.05";
}
