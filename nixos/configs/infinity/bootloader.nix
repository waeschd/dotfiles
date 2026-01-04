{ config, lib, pkgs, inputs, ... }:

{
  boot = {

    # Plymouth
    plymouth = {
      enable = true;
      theme = "spinner_alt"; # Change to `bgrt` for OEM logo (Fedora look)
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "loader" "darth_vader" "glitch" "green_loader" "spinner_alt" ];
        })
      ];
    };

    loader = {
      # 1. EFI settings
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      # 2. Bootloader
      systemd-boot.enable = false;

      grub = {
        enable = true;
        theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
      };

      refind = {
        enable = false;
        maxGenerations = 10;

        # This part is required to tell rEFInd to load the themes
        extraConfig = ''
          include themes/rEFInd-glassy/theme.conf
        '';
      };
    };
  };
}
