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

  home.packages = [
    inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default # HyprMod
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli # Caelestia Shell
    inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default     # Caelestia CLI (`caelestia` binary on PATH)
  ];
}
