# TODO: add hyperv stuff?
# TODO: test on SLY ?

# TODO: ?

{ config, lib, pkgs, ... }:

let
  nixosHardware = builtins.fetchTarball
    "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
  hostname = "goonhab";
in
{
  imports = [
    ../modules/common.nix

    ../modules/mixin-openhab.nix
    ../modules/mixin-sshd.nix

    "${builtins.toString nixosHardware}/common/cpu/intel"
  ];

  config = {
    system.stateVersion = "18.09"; # Did you read the comment?
    time.timeZone = "America/Chicago";
    services.timesyncd.enable = true;

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      
      # TODO: enable hyperv stuff here
      initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" "intel_agp" "i915" ];
      
      # TODO: switch others to grub too? for submenus and other stuff? idk?
      # is there anything systemd-boot CAN do that grub CANT?

      loader = {
        grub.enable = true; # ?
        # use a legacy install for hyperv since I think it
        # still defaults to gen1
      };
    };
    networking = {
      hostId = "44b1a528";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [];
      networkmanager.enable = true;
    };
    services.resolved.enable = true;
    
    nix.maxJobs = 4;
    nix.nixPath = [
      "/etc/nixos"
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/${hostname}.nix"
    ];
  };
}

