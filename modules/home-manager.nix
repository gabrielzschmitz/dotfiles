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
        craftapps
        cli
        dev
        formatters
        dunst
        fastfetch
        fonts
        git
        gpg
        nvim
        nnn
        ssh
        xdg
        gui-theme
      ];
    };
  };

  flake.modules.nixos.home-manager-vm = {
    home-manager.users.gabrielzschmitz.imports = with self.modules.homeManager; [
      services
    ];
  };
}
