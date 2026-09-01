{ config, pkgs, inputs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos/nixos-dotfiles";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in

{
  # ------------------------ Hyprland ------------------------- #
  xdg.configFile.hypr = {
    source = create_symlink "${dotfiles}/hypr";
    recursive = true;
  };

  # ------------------------ Caelestia Shell ------------------------- #
  xdg.configFile.caelestia = {
    source = create_symlink "${dotfiles}/caelestia";
    recursive = true;
  };

  home.packages = [
    inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default # HyprMod
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli # Caelestia Shell
    inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default     # Caelestia CLI (`caelestia` binary on PATH)
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    pkgs.brightnessctl # Brightness control (keybinds + Caelestia Shell OSD)
    pkgs.grim # Screenshot capture backend (Caelestia CLI `caelestia screenshot`)
    pkgs.swappy # Screenshot annotate/save UI used by Caelestia CLI
  ];
}
