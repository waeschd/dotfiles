{ config, lib, pkgs, ... }:

{
  # ----- Display Manger ------- #
  # Use SDDM as Display Manager
  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];
  };

  # ---------------------- #

  # ----- Desktop Environment ------- #
  programs.hyprland = {
    enable = false;
    xwayland.enable = true;
  };

  # Plasma6 DE
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    dolphin
    gwenview
    elisa
    kate
    konsole
    okular
    plasma-systemmonitor
  ];
  # ---------------------- #

  # ----- Fonts ------- #
  fonts.packages = with pkgs; [
    maple-mono.NL-OTF
  ];
  # ---------------------- #
}
