{ config, lib, pkgs, modulesPath, ... }:

let
in {
  imports = [
    ../../profiles/cloudvm
    "${modulesPath}/virtualisation/azure-image.nix"
  ];

  system.nixos.stateVersion = "18.09";

  userOptions.cole = { tmuxColor="blue"; bashColor="1;34"; };

  networking.hostName = "z";
  time.timeZone = "America/Los_Angeles";
  i18n.consoleFont = "Lat2-Terminus16";

  nix.maxJobs = 16;
  nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
}
