{ config, lib, pkgs, ... }:

{
  users.users = {
    seru = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "kvm" "video" "input" "podman"];
      packages = with pkgs; [
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
    };
  };
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
