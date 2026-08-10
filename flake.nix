{
  description = "Paddy Setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs : {
    nixosConfigurations.paddy = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      system = "x86_64-linux";
      modules = [
        # 1. Inputs
        inputs.nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.seru = import ./home.nix;
            backupFileExtension = "backup";
          };
        }

        # 2. Local Modules
        ./hardware-configuration.nix

        ./bootloader.nix
        ./configuration.nix
        ./desktop_environment.nix
        ./flatpak.nix
        ./luks.nix
        ./networking.nix
        ./programs.nix
        ./users.nix
      ];
    };
  };
}
