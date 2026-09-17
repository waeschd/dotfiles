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

  # Plasma6 already wires up xdg-desktop-portal-kde + a gtk fallback for GTK
  # apps (Vivaldi, GIMP, ...); just make kde the preferred backend so native
  # dialogs/screenshare/etc. go through KWin.
  xdg.portal.config.common.default = [ "kde" "gtk" ];
  # ---------------------- #

  # ----- Fonts ------- #
  # System-wide default fonts: whatever an app resolves via fontconfig's
  # generic "sans-serif" / "monospace" families (GTK, Qt, Electron, browsers,
  # ...) falls back to these. Apps that set an explicit
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
  # Plasma auto-starts KWallet, but it still needs to be unlocked with the
  # login password at session start - the SDDM PAM hook below does that,
  # the same way GDM does it for GNOME's keyring.
  security.pam.services.sddm.enableKwallet = true;
  # ---------------------- #
}
