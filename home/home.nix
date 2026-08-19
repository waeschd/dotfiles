{ config, pkgs, ... }: 

{
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/fastfetch.nix
    ./modules/shell.nix
    ./modules/terminal.nix
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
    eza
    ghgrab
    tokei
    tree
    wget
    vivaldi
    gimp
    distrobox
    gnome-boxes
    papers
    eog
    ffmpeg
    baobab
    gnome-calculator
    gnome-disk-utility
    gnome-text-editor
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

