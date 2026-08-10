{ config, pkgs, ... }: 

{
  imports = [
    ./modules/neovim.nix
  ];

  home.stateVersion = "26.05";
  home.username = "seru";
  home.homeDirectory = "/home/seru";

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Sebastian Russer";
        email = "sebastian.russer@fau.de";
      };
      aliases = {
        word-diff = "diff --word-diff=color -b";
	pr = "pull --rebase";
      };
      core = {
        editor = "nvim";
	page = "diffnav";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      interactive.diffFilter = "diffnav --color-only";
      diffnav.side-by-side = true;
      merge.conflictStyle = "zdiff3";
    };
  };

  programs.bash = {
    enable = true;
  };

  home.packages = with pkgs; [
    onefetch
    bat
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

