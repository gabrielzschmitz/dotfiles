{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      zen-browser,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit zen-browser;
        };

        modules = [
          ./hardware-configuration.nix
          ./configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit zen-browser;
            };

            home-manager.users.gabrielzschmitz = import ./home.nix;
          }
        ];
      };

      devShells.${system}.tomato-c = pkgs.mkShell {
        packages = with pkgs; [
          gcc
          gnumake
          pkg-config
          bear
          ncurses
          libnotify
          fish
        ];

        shellHook = ''
            export TOMATO_FISH_CONFIG="$TMPDIR/tomato-c-fish"

            cat > "$TOMATO_FISH_CONFIG" <<'EOF'
          function fish_prompt
              switch $fish_bind_mode
                  case default
                      set_color --bold RED
                      echo -n '[TOMATO.C] '
                      set_color --bold cyan
                      echo -n '[N]'

                  case insert
                      set_color --bold RED 
                      echo -n '[TOMATO.C] '
                      set_color --bold magenta
                      echo -n '[I]'

                  case replace replace_one
                      set_color --bold RED
                      echo -n '[TOMATO.C] '
                      set_color --bold red
                      echo -n '[R]'

                  case visual
                      set_color --bold RED
                      echo -n '[TOMATO.C] '
                      set_color --bold yellow
                      echo -n '[V]'

                  case '*'
                      set_color --bold RED
                      echo -n '[TOMATO.C] '
                      set_color --bold cyan
                      echo -n '[?]'
              end

              set_color normal
              echo -n ' '

              set_color --bold cyan
              echo -n $PWD
              set_color normal

              echo
              echo -n '❯ '
          end

          set -g fish_key_bindings fish_vi_key_bindings
          EOF

            exec fish --init-command "source '$TOMATO_FISH_CONFIG'"
        '';
      };
    };
}
