{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    config = { common = { default = [ "gtk" ]; }; };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services.flatpak = {
    enable = true;
    update.auto = { enable = true; onCalendar = "weekly"; };
    packages = [
      "org.flozz.yoga-image-optimizer" # Reduce image file size
      "net.mkiol.SpeechNote"
    ];
  };
}
