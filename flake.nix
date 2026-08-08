{
  description = "Infinity Setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
  };

  outputs = { nixpkgs, ... } @ inputs : {
    nixosConfigurations.paddy = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      system = "x86_64-linux";
      modules = [
        # 1. Inputs
        inputs.nix-flatpak.nixosModules.nix-flatpak

        # 2. Local Modules
        ./hardware-configuration.nix

        ./bootloader.nix
        ./configuration.nix
        ./desktop_environment.nix
        ./flatpak.nix
        ./luks.nix
        ./networking.nix
        ./programs.nix
        ./user.nix
      ];
    };
  };
}
