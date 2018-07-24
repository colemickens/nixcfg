{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../profiles/gui
    ./hardware-configuration.nix
  ];

  system.nixos.stateVersion = "18.09";

  userOptions.cole = { tmuxColor="magenta"; bashColor="1;35"; };

  time.timeZone = "America/Los_Angeles";

  # hidpi stuff
  boot.earlyVconsoleSetup = true;
  fonts.fonts = with pkgs; [ terminus_font ];
  i18n.consolePackages = [ pkgs.terminus_font ];
  i18n.consoleFont = "ter-v32n";

  # ignore psmouse, errors on Dell HW
  boot.blacklistedKernelModules = [ "psmouse" ];

  # newer kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  services.fwupd.enable = true;

  # pretty boot
  #boot.plymouth.enable = true;

  nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    #enableAllFirmware = true;
    u2f.enable = true;
  };

  powerManagement.enable = true;
  services.tlp.enable = true;

  networking = {
    hostName = "xeep";
    networkmanager.enable = true;
  };
}
