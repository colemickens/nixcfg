{ modulesPath, config, lib, pkgs, inputs, ... }: {

  imports = [
    ../hcloud-amd64-dev1/configuration.nix
  ];

  config = {
    nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";

    disko.devices.disk.disk1.device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
    disko.devices.disk.disk2.device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:2";
  };
}
