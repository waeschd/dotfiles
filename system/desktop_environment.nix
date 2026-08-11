{ config, lib, pkgs, inputs, ... }:

{
  # ----- Packages ------- #
    environment.systemPackages = with pkgs; [
    sddm-astronaut # Use SDDM as Display Manager
    inputs.caelestia-shell.packages.${pkgs.system}.with-cli # Caelestia Shell
  ];
  # ---------------------- #

  # ----- Display Manger ------- #
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];
  };

  # ---------------------- #

  # ----- Desktop Environment ------- #
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

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;  # lets X11-only apps still run under Hyprland
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  # ---------------------- #
}
