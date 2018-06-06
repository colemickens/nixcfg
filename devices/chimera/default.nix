{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../profiles/mediaserver
    ./hardware-configuration.nix
  ];

  system.nixos.stateVersion = "18.09"; # Did you read the comment?

  userOptions.cole = { tmuxColor="cyan"; bashColor="1;36"; };

  networking.hostName = "chimera";
  i18n.consoleFont = "Lat2-Terminus16";
  time.timeZone = "America/Los_Angeles";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    u2f.enable = true;
  };

  powerManagement.enable = true;
  services.tlp.enable = true;

  networking.networkmanager.enable = true;
}
