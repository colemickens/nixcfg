{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../profiles/common
    ../../profiles/gui
    ../../profiles/cloudvm
    ./hardware-configuration.nix
  ];

  networking.hostName = "slynux";
  system.nixos.stateVersion = "18.09";

  nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  time.timeZone = "America/Los_Angeles";

  services.xserver.videoDrivers = [ "nvidia" ];
  #guiOptions.desktopEnvironment = "kde";


  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    u2f.enable = true;
  };

  #powerManagement.enable = true;
  #services.tlp.enable = true;

  # TODO: investigate using the nvidia driver here if we're stuck with x11 anyway...

  networking.networkmanager.enable = true;
}
