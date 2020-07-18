{ pkgs, config, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    "${modulesPath}/virtualisation/azure-image.nix"

    ../../config-home/users/cole/user.nix
  ];

  config = {
    system.stateVersion = "20.03";
    virtualisation.azureImage.diskSize = 2500;

    fileSystems."/" = {
      fsType = "ext4";
      autoResize = true;
    };
    
    boot = {
      cleanTmpDir = true;
      growPartition = true; # TODO: This doesn't work?
      kernelPackages = pkgs.linuxPackages_latest;
    };
    nix = rec {
      trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
      allowedUsers = trustedUsers;
      nrBuildUsers = 128;
      package = pkgs.nixFlakes;
    };

    services = {
      hydra = {
        enable = true;
        hydraURL = "https://hydra.cleo.cat";
        notificationSender = "hydra@cleo.cat";
        #buildMachinesFile = [];
        useSubstitutes = true;
      };
    };

    networking.hostName = "azbldr";
    documentation.nixos.enable = false;
    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
