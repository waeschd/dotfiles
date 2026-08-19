{ config, ... }:

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
}
