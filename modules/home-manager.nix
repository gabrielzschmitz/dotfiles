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
        pdf
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
        docker
        music
        thunar
        services
      ];
    };
  };

  flake.modules.nixos.home-manager-vm = {
    imports = [
      self.modules.nixos.desktop
    ];
  };

}
