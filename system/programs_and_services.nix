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

  # Container
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows using `docker` commands which are translated to `podman` commands
      dockerSocket.enable = true; # External tools like VS Code "Dev Containers," Portainer, or specific Python/Go scripts may look for `/var/run/docker.sock`
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };
  # ---------------------- #




  # ----- Programs ------- #
  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
    papirus-icon-theme
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
