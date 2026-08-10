{ config, pkgs, ... }: 

{
  home.stateVersion = "26.05";
  home.username = "seru";
  home.homeDirectory = "/home/seru";

  programs.git.enable = true;
  programs.bash = {
    enable = true;
  };

  home.packages = with pkgs; [
    tree
    neovim
    wget
    vivaldi
    vscode
    gimp
    distrobox
    gnome-boxes
    papers
    eog
    gnome-calculator
    ffmpeg
    baobab
    gnome-disk-utility
    fish
    ptyxis
    nautilus
    mission-center
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
  ];
}

# gdb
# make
# cmake
# gcc
# g++
# valgrind
# rustup
# tokei
# onefetch
