{ lib, pkgs, ... }:

# KDE apps I don't use - hidden from this user's application menu in favor
# of the GTK/GNOME equivalent installed alongside each one, without
# uninstalling the KDE app itself. Other users on the machine still see it
# normally.
#
# XDG desktop-entry lookup checks ~/.local/share/applications before the
# system directories, so dropping a stub override with `NoDisplay=true`
# there is enough to hide the app from menus/launchers for this user only;
# the real .desktop file and package are untouched.
let
  replacements = {
    "org.kde.ark" = pkgs.file-roller;
    "org.kde.dolphin" = pkgs.nautilus;
    "org.kde.gwenview" = pkgs.eog;
    "org.kde.kate" = pkgs.gnome-text-editor;
    "org.kde.konsole" = pkgs.ptyxis;
    "org.kde.okular" = pkgs.papers;
    "org.kde.spectacle" = pkgs.gnome-screenshot;
  };

  # KDE apps hidden with no direct GTK/GNOME equivalent installed.
  noReplacement = [
    "org.kde.elisa"
    "org.kde.khelpcenter"
  ];
in
{
  home.packages = lib.attrValues replacements ++ [
    # Adds an "Open Terminal Here" entry to Nautilus's context menu.
    pkgs.nautilus-python
    pkgs.nautilus-open-any-terminal

    # Kept alongside org.kde.plasma-systemmonitor rather than replacing it.
    pkgs.mission-center
  ];

  # Outside GNOME, Nautilus doesn't know where to find the nautilus-python
  # bridge (libnautilus-python.so) that lets it load .py extensions like
  # the one above, so point it there explicitly.
  home.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";

  dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal".terminal = "kitty";

  home.file = lib.listToAttrs (
    map (id: {
      name = ".local/share/applications/${id}.desktop";
      value.text = ''
        [Desktop Entry]
        Type=Application
        Name=${id}
        NoDisplay=true
      '';
    }) (lib.attrNames replacements ++ noReplacement)
  );
}
