{ config, lib, pkgs, ... }:

{
  users.users = {
    seru = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "kvm" "video" "input" "podman"];
    };
  };
}

