{ config, pkgs, ... }: 

{
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/fastfetch.nix
    ./modules/shell.nix
  ];

  home.stateVersion = "26.05";
  home.username = "seru";
  home.homeDirectory = "/home/seru";

  programs.bash = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "fish";
    };
  };

  home.packages = with pkgs; [
    maple-mono.NL-NF
    onefetch
    kitty
    bat
    diffnav
    eza
    ghgrab
    tokei
    tree
    wget
    vivaldi
    vscode
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

