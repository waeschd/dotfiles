{ config, lib, pkgs, inputs, ... }:

{
  boot = {
    # ----- Plymouth ------ #
    plymouth = {
      enable = true;
      theme = "glitch"; # Change to `bgrt` for OEM logo (Fedora look)
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "loader" "darth_vader" "glitch" "green_loader" "spinner_alt" ];
        })
      ];
    };
    # ---------------------- #

    # ----- Loader ------ #
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
        theme = inputs.nixos-grub-themes.packages.${pkgs.stdenv.hostPlatform.system}.nixos;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
      };
    };
    # ---------------------- #

    # ----- initrd ------ #
    initrd = {
      systemd.enable = true; # Enables systemd in initramfs, required for Plymouth graphical display during LUKS unlock
      verbose = false;

      # LUKS
      kernelModules = [ "cryptd" ];
      luks.devices."crypt1".device = "/dev/disk/by-label/NIXOS_LUKS1";
    };
    # ---------------------- #

    # ----- Kernel ------ #
    kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # ---------------------- #
  };
}
