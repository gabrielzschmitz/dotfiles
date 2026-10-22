{ inputs, self, ... }:

{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      users.gabrielzschmitz.imports = with self.modules.homeManager; [
        user
        fish
        display
        zen
        desktop
        cli
        dev
        formatters
        dunst
        fastfetch
        fonts
        git
        gpg
        nvim
        services
        ssh
        xdg
      ];
    };
  };
}
