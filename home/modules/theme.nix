{ pkgs, ... }:

{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    # adw-gtk3 is a libadwaita-style GTK3 theme that understands the same
    # @define-color names (accent_color, window_bg_color, ...) Caelestia
    # writes into ~/.config/gtk-{3,4}.0/gtk.css on every `caelestia scheme
    # set`. Caelestia already flips the active theme at runtime via
    # `dconf write /org/gnome/desktop/interface/gtk-theme` (to
    # adw-gtk3-dark/-light), but that only works if the theme is actually
    # installed and on XDG_DATA_DIRS - stock Adwaita ignores those colours.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  # Qt platform theme plugin, so native Qt dialogs (e.g. Quickshell/Caelestia's
  # own file pickers) pick up the GTK-side icon theme/colours instead of
  # falling back to bare, icon-less default Qt styling. Caelestia already
  # writes its config at ~/.config/qtengine/config.json on every
  # `caelestia scheme set`; this just installs the plugin and tells Qt to use it.
  home.packages = [ pkgs.qtengine ];

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qtengine";
    QT_PLUGIN_PATH = "${pkgs.qtengine}/lib/qt-6/plugins:$QT_PLUGIN_PATH";
  };
}
