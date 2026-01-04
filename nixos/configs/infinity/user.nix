{ config, lib, pkgs, ... }:

{
  users.users = {
    seru = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "kvm" "video" "input" "podman"];
      packages = with pkgs; [
        vivaldi
        code
        gimp
        distrobox
        gnome-boxes
        papers
        fish
      ];
    };
  };
}

# gdb
# make
# cmake
# gcc
# g++
# valgrind
# rustup
# tokei
# onefetch
