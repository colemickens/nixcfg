{ pkgs, lib, config, modulesPath, inputs, ... }:

{
  imports = [
    # this make the azure go vroom
    inputs.nixos-azure.nixosModules.azure-image

    # everything for a non-gui interactive session
    ../../profiles/interactive.nix
    ../../mixins/loremipsum-media/rclone-mnt.nix
    #../../mixins/jellyfin.nix
    ../../mixins/plex.nix
    #../../mixins/xmrig.nix

    # specific persistent services to run in Azure
    #./services.nix
    
    # github action runner
    ../../mixins/runner.nix

    #./hydra/hydra.nix
    ./nginx.nix
  ];

  config = {
    virtualisation.azure.image.diskSize = 30000;
    system.stateVersion = "21.03";

    # azdev/jellyfin specific
    services.nginx.recommendedProxySettings = true;
    services.nginx.virtualHosts."jellyfin.${config.networking.hostName}.ts.r10e.tech" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8096/";
          proxyWebsockets = true;
        };
      };
    };
    services.nginx.virtualHosts."plex.${config.networking.hostName}.r10e.tech" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:32400/";
          proxyWebsockets = true;
          #proxy_set_header = "Host $host";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d '/run/state/ssh' - root - - -"

      "d '/var/lib/tailscale' - root - - -"
      "d '/run/state/tailscale' - root - - -"

      "d '/run/state/plex' - plex - - -"
      "d '/var/lib/plex' - plex - - -"
      
      "d '/run/state/postgresql' - postgres - - -"
      "d '/var/lib/postgresql' - postgres - - -"
      
      "d '/run/state/hydra' - hydra - - -"
      "d '/var/lib/hydra' - hydra - - -"
    ];

    # sshd keys come from persistent location (/run/state is bound to zfs vol)
    services.openssh = {
      enable = true;
      hostKeys = [
        { path = "/run/state/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
        { path = "/run/state/ssh/ssh_host_rsa_key";     type = "rsa"; }
      ];
    };

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
      "/var/lib/tailscale" = {
        fsType = "none";
        options = [ "bind" ];
        device = "/run/state/tailscale";
      };
      "/var/lib/plex" = {
        fsType = "none";
        options = [ "bind" ];
        device = "/run/state/plex";
      };
      "/var/lib/hydra" = {
        fsType = "none";
        options = [ "bind" ];
        device = "/run/state/hydra";
      };
      "/var/lib/postgresql" = {
        fsType = "none";
        options = [ "bind" ];
        device = "/run/state/postgresql";
      };
      "/run/state" = {
        fsType = "zfs";
        device = "azpool/state";
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
