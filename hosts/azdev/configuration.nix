{ pkgs, config, modulesPath, inputs, ... }:

{
  imports = [
    inputs.nixos-azure.nixosModules.azure-image
    ../../profiles/user.nix
  ];

  config = {
    system.stateVersion = "20.03";
    virtualisation.azure.image.diskSize = 2500;

    fileSystems."/" = {
      fsType = "ext4";
      autoResize = true;
    };
    
    boot = {
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
