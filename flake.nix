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
        overlays = [ (import ./pkgs) ];
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit zen-browser;
        };

        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager

          {
            nixpkgs.overlays = [ (import ./pkgs) ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit zen-browser;
            };

            home-manager.users.gabrielzschmitz = import ./home;
          }
        ];
      };

      devShells.${system}.tomato-c = import ./shells/tomato-c.nix { inherit pkgs; };
    };
}
