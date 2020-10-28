{ pkgs, config, modulesPath, inputs, ... }:

{
  imports = [
    inputs.nixos-azure.nixosModules.azure-image

    #../../mixins/reposup.nix

    ../../profiles/user.nix
  ];

  config = {
    system.stateVersion = "20.03";
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
      trustedUsers = [ "root" "@wheel" "azureuser" "cole" ];
      allowedUsers = trustedUsers;
      nrBuildUsers = 128;
      package = pkgs.nixUnstable;
    };

    networking.hostName = "azbldr";
    documentation.nixos.enable = false;
    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
