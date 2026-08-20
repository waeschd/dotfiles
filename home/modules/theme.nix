{ pkgs, ... }:

{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
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
