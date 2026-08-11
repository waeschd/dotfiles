{ config, lib, pkgs, ... }:

{
  # ----- Services ------- #
  # OpenSSH daemon
  services.openssh.enable = false;

  # Bluetooh
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound
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

  # Battery Threshold
  systemd.services.battery-threshold = {
    description = "Set battery charge thresholds";
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo 70 > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
    serviceConfig.Type = "oneshot";
  };
  # ---------------------- #




  # ----- Programs ------- #
  environment.systemPackages = with pkgs; [
    neovim
    efibootmgr
    git
    curl
    papirus-icon-theme
  ];

  # My Traceroute, combines the functionality of the 'ping' and 'traceroute' into a single interface.
  programs.mtr.enable = true;

  # NixOS Wiki recommends also enabling `fish` here
  programs.fish.enable = true;

  # GnuPG, tool for encrypting and signing data.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # ---------------------- #
}
