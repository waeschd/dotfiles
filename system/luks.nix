{ config, lib, pkgs, ... }:

{
  boot.initrd = {
    systemd.enable = true; # Enables systemd in initramfs, required for Plymouth graphical display during LUKS unlock
    kernelModules = [ "cryptd" ];
    luks.devices."crypt1".device = "/dev/disk/by-label/NIXOS_LUKS1";
  };
}
