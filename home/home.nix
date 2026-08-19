{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/fastfetch.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/theme.nix
    ./modules/hide-plasma-apps.nix
    ./modules/hyprland.nix
  ];

  home.stateVersion = "26.05";
  home.username = "seru";
  home.homeDirectory = "/home/seru";

  programs.vscode.enable = true;

  home.packages = with pkgs; [
    maple-mono.NL-NF
    onefetch
    btop
    docker-compose
    gdb
    ncdu
    wl-clipboard-x11
    bat
    diffnav
    wl-clipboard
    eza
    ghgrab
    tokei
    tree
    wget
    vivaldi
    gimp
    distrobox
    gnome-boxes
    ffmpeg
    baobab
    gnome-calculator
    gnome-disk-utility
    fish
    foliate
    czkawka
    gnome-frog
    distroshelf
    spotify
    morphosis
    constrict
    upscaler
    devtoolbox
    freecad
    localsend
    thunderbird
    signal-desktop
    zotero
    zoom-us
    obs-studio
    nextcloud-client
    onlyoffice-desktopeditors

    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli # Caelestia Shell
    inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default # HyprMod
  ];
}

