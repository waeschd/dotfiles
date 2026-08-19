{ config, lib, pkgs, ... }:

let
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
  };
in
{
  # ----- Packages ------- #
  environment.systemPackages = [
    sddm-astronaut # Use SDDM as Display Manager
  ];
  # ---------------------- #

  # ----- Display Manger ------- #
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia # Required for video backgrounds/audio
    ];
  };

  # ---------------------- #

  # ----- Desktop Environment ------- #
  # Plasma6 DE
  services.desktopManager.plasma6.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;  # lets X11-only apps still run under Hyprland
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };
  # ---------------------- #
}
