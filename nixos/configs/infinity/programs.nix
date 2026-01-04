{ config, lib, pkgs, ... }:

{
  # ----- Services ------- #
  # OpenSSH daemon.
  services.openssh.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  # ---------------------- #




  # ----- Programs ------- #
  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
  ];

  # My Traceroute, combines the functionality of the 'ping' and 'traceroute' into a single interface.
  programs.mtr.enable = true;

  # GnuPG, tool for encrypting and signing data.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # ---------------------- #
}