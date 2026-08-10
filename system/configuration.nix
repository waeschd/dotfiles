{ config, lib, pkgs, inputs, ... }:

{
  # --------------- General Stuff --------------------- #

  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel

    # Clean up the boot output (Silent Boot)
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  time.timeZone                = "Europe/Berlin";
  hardware.enableAllFirmware   = true;
  nixpkgs.config.allowUnfree   = true;
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows using `docker` commands which are translated to `podman` commands
      dockerSocket.enable = true; # External tools like VS Code "Dev Containers," Portainer, or specific Python/Go scripts may look for `/var/run/docker.sock`
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
