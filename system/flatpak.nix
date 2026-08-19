{ config, lib, pkgs, ... }:

{
  services.flatpak = {
    enable = true;
    update.auto = { enable = true; onCalendar = "weekly"; };
    packages = [
      "org.flozz.yoga-image-optimizer" # Reduce image file size
      "net.mkiol.SpeechNote"
    ];
  };
}
