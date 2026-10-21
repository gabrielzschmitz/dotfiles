{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.gabrielzschmitz = {
    isNormalUser = true;
    description = "gabrielzschmitz";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}
