{ pkgs, config, modulesPath, inputs, ... }:

{
  imports = [
    inputs.nixos-azure.nixosModules.azure-image

    #../../mixins/reposup.nix

    ../../profiles/user.nix
    ../../profiles/interactive.nix
  ];

  config = {
    system.stateVersion = "21.03";
    virtualisation.azure.image.diskSize = 30000;

    fileSystems."/" = {
      fsType = "ext4";
      autoResize = true;
    };

    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;
      growPartition = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };
    nix = rec {
      #trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
      #allowedUsers = trustedUsers;
      nrBuildUsers = 128;
      #package = pkgs.nixUnstable;
    };

    environment.systemPackages = with pkgs; [
      cryptsetup
    ];

/*
    fileSystems = {
      "/nix" = {
        device = "/dev/disk/by-partlabel/nix";
      };
      "/data" = {
        device = "/dev/disk/by-partlabel/azdev_data";
      };
      "/home" = {
        fsType = "none"; options = [ "bind" ]; device = "/data/home";
      };
      "/var/lib/docker" = {
        fsType = "none"; options = [ "bind" ]; device = "/data/var/lib/docker";
      };
    };
*/
    networking.hostName = "azdev";
    documentation.nixos.enable = false;
    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
