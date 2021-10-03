{ pkgs, config, inputs, modulesPath, ... }:

{
  imports = [
    ./oci-common.nix

    ../../profiles/user.nix
    ../../profiles/interactive.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix
  ];

  config = {
    networking.hostName = "oracular";
    
    fileSystems = {
      "/" = {
        fsType = "ext4";
      };
      "/boot" = {
        fsType = "vfat";
        options = [];
      };
    };
    
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.device = "nodev";

    networking.hostId = "abcdcadb"; # required for zfs use
  };
}
