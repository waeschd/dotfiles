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

  # ----- Fonts ------- #
  # System-wide default fonts: whatever an app resolves via fontconfig's
  # generic "sans-serif" / "monospace" families (GTK, Qt, Quickshell/Caelestia,
  # Electron, browsers, ...) falls back to these. Apps that set an explicit
  # font (e.g. kitty) are unaffected.
  fonts = {
    packages = with pkgs; [
      maple-mono.NL-NF # already installed via home-manager too, but needed
                        # here so the *system* fontconfig cache knows about it
      quicksand         # rounded geometric sans, stand-in for SF Pro Rounded
                         # (Apple-proprietary, not distributable in nixpkgs)
      adwaita-fonts     # provides Adwaita Sans/Mono, GNOME's default typeface
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Adwaita Sans" ];
      monospace = [ "Maple Mono NL NF" ];
    };
  };
  # ---------------------- #

  # ----- Secret Service (keyring) ------- #
  # Plasma auto-starts + unlocks KWallet via PAM, but Hyprland has no DE to do that,
  # so apps like Vivaldi/Chromium fail to unlock their secure key store there.
  # gnome-keyring provides the same org.freedesktop.secrets API and gets unlocked
  # via PAM at SDDM login, same as KWallet does for Plasma.
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # conflicts with programs.ssh.startAgent
  security.pam.services.sddm.enableGnomeKeyring = true;
  # ---------------------- #
}
