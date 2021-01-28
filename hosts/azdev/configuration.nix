{ pkgs, config, modulesPath, inputs, ... }:

{
  imports = [
    # this make the azure go vroom
    inputs.nixos-azure.nixosModules.azure-image

    # everything for a non-gui interactive session
    ../../profiles/interactive.nix

    # specific persistent services to run in Azure
    ./services.nix
  ];

  config = {
    virtualisation.azure.image.diskSize = 30000;

    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = false; # override for builder/devenv
    nix.nrBuildUsers = 128;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    # TODO: move to base azure image
    environment.systemPackages = with pkgs; [
      cryptsetup zfs
    ];

    fileSystems = {
      "/" = {
        fsType = "ext4";
        autoResize = true;
      };
      "/home" = {
        fsType = "zfs";
        device = "azpool/home";
      };
      # "/nix" = {
      #   device = "/dev/disk/by-partlabel/nix";
      # };
      # "/data" = {
      #   device = "/dev/disk/by-partlabel/azdev_data";
      # };
      # "/home" = {
      #   fsType = "none"; options = [ "bind" ]; device = "/data/home";
      # };
      # "/var/lib/docker" = {
      #   fsType = "none"; options = [ "bind" ]; device = "/data/var/lib/docker";
      # };
    };

    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];

      growPartition = true;
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        "mitigations=off" # YOLO
      ];
    };

    networking = {
      hostId = "aaaaaa0a";
      hostName = "azdev";
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 5900 22 ];
      networkmanager.enable = false;
      useNetworkd = true;
      useDHCP = false;
      interfaces."eth0".useDHCP = true;
      search = [ "ts.r10e.tech" ];
    };
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" ];
    systemd.network.enable = true;

    # TODO: move to base image
    # these should be true for ALL azure images
    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
