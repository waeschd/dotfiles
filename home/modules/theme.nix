{ pkgs, ... }:

{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    # adw-gtk3 is a libadwaita-style GTK3 theme, so GTK3 apps match the
    # GTK4/libadwaita look instead of falling back to stock Adwaita.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

}
