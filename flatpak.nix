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
      "com.github.johnfactotum.Foliate" # Reading .epub files
      "com.github.qarmin.czkawka" # Finding duplicate/big files
      "com.github.tenderowl.frog" # Extract text from images
      "com.nextcloud.desktopclient.nextcloud"
      "com.obsproject.Studio"
      "com.ranfdev.DistroShelf"   # For graphical managing of DistroBox Container
      "com.spotify.Client"
      "garden.jamie.Morphosis"    # Convert files
      "io.github.wartybix.Constrict" # Reduce video file size
      "org.flozz.yoga-image-optimizer" # Reduce image file size
      "io.gitlab.theevilskeleton.Upscaler"
      "io.missioncenter.MissionCenter"
      "me.iepure.devtoolbox"
      "net.mkiol.SpeechNote"
      "org.freecad.FreeCAD"
      "org.jamovi.jamovi" # Statistic Plotting
      "org.localsend.localsend_app"
      "org.mozilla.Thunderbird"
      "org.onlyoffice.desktopeditors"
      "org.signal.Signal"
      "org.zotero.Zotero"
      "us.zoom.Zoom"
    ];
  };
}
