{
  lib,
  ...
}:

{
  # Placeholder: generate this file on the target laptop before deploying.
  #
  #   sudo nixos-generate-config --show-hardware-config \
  #     > ~/.dotfiles/hosts/machine/hardware-configuration.nix
  #
  # Then review the generated file and commit it. The assertion below keeps an
  # accidental build or activation from producing an unbootable system.
  assertions = [
    {
      assertion = false;
      message = ''
        hosts/machine/hardware-configuration.nix is still a placeholder.
        Generate it on the machine with:
          sudo nixos-generate-config --show-hardware-config > ~/.dotfiles/hosts/machine/hardware-configuration.nix
      '';
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
