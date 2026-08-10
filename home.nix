{ config, pkgs, ... }: 

{
  home.stateVersion = "26.05";
  home.username = "seru";
  home.homeDirectory = "/home/seru";
  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos";
    };
  };
}
