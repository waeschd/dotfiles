{ config, lib, pkgs, inputs, ... }:

{
  # ----- Users ------- #
  users.users = {
    seru = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "kvm" "video" "input" "podman"];
    };
  };
  # ---------------------- #

  # ----- Networking ------- #
  networking = {
    hostName = "paddy";
    networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  };
  # ---------------------- #

  # ----- Fonts ------- #
  fonts.packages = with pkgs; [
    maple-mono.NL-OTF
  ];
  # ---------------------- #

  time.timeZone                = "Europe/Berlin";
  hardware.enableAllFirmware   = true;
  nixpkgs.config.allowUnfree   = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
