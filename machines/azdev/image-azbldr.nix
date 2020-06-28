{ pkgs, config, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    "${modulesPath}/virtualisation/azure-image.nix"

    ../../config-nixos/loremipsum-media/rclone-mnt.nix
    ../../config-nixos/loremipsum-media/rclone-cmd.nix
    ../../config-nixos/mixin-plex.nix
    ../../config-nixos/mixin-cachix.nix

    ../../config-home/users/cole/core.nix
  ];

  config = {
    system.stateVersion = "20.03";
    virtualisation.azureImage.diskSize = 2500;

    fileSystems."/".autoResize = true;
    
    boot = {
      cleanTmpDir = true;
      growPartition = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };
    nix = rec {
      trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
      allowedUsers = trustedUsers;
      nrBuildUsers = 128;
    };
    networking.hostName = "azbldr";
    documentation.nixos.enable = false;
    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
