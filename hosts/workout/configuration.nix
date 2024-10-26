{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.hostName = "workout";
  networking.defaultGateway  = "10.5.0.1";
  networking.nameservers  = [ "10.5.0.1" ];
  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "10.5.0.14";
    prefixLength = 16;
  } ];

  # SSH
  services.openssh.enable = true;

  # QEMU guest tools
  environment.systemPackages = [ pkgs.spice ];
  services.spice-vdagentd.enable = true;
  services.spice-webdavd.enable = true;
  services.qemuGuest.enable = true;

  # Run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;

  # Add a default user
  users.users.emil = {
    isNormalUser  = true;
    initialPassword = "changeme";
    home  = "/home/emil";
    description  = "emil";
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys  = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUvldrwH+VVVUu+mdmvpbUlQzRIkT7C4PcSEwDQQQml emil@local" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
