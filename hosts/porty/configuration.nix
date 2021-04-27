# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  tailsVer = "4.18";
  tailsIsoName = "tails-amd64-${tailsVer}.iso";
  tailsIso = builtins.fetchurl {
    url = "https://tails.interpipe.net/tails/stable/tails-amd64-${tailsVer}/${tailsIsoName}";
    sha256 = "0maj7hvgn7psxhx2nvn6aha89fc325g4b4bb4d4dpd1mlyv1wr1z";
  };
in {
  imports = [
    ./hardware-configuration.nix

    ../../mixins/common.nix

    ../../profiles/user.nix
    ../../profiles/interactive.nix
    ../../profiles/specialisations.nix

    ../../mixins/libvirt.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
  ];

  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.gpg.package = pkgs.gnupg23;
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.devices = [ "nodev" ];
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.supportedFilesystems = [ "zfs" ];

    # copy the iso(s) to the large /boot since / is encrypted!
    # TODO: develop this into an entire module that will auto-pop and auto-prune iso
    # maybe some scripting or copy mappings from others to know where kernel/initrds are
    boot.loader.grub.extraPrepareConfig = ''
      mkdir -p /boot/iso
      [[ ! -f "/boot/iso/${tailsIsoName}" ]] && cp "${tailsIso}" "/boot/iso/${tailsIsoName}"
    '';
    boot.loader.grub.extraEntries = ''
      menuentry "[[tails-${tailsVer}]] [Crypto] + [Living Will]" {
        set isofile="/boot/iso/${tailsIsoName}"
        loopback loop (hd0,1)$isofile
        linux (loop)/live/vmlinuz boot=live config noswap nopersistent iso-scan/filename=$isofile nomodeset toram
        initrd (loop)/live/initrd.img
      }
    '';

    boot.kernelParams = [ "mitigations=off" ];

    nix.nixPath = [];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [ hdparm ];

    networking.hostName = "porty"; # Define your hostname.
    networking.hostId = "abbadaba";
    
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      cpu.amd.updateMicrocode = true;
    };

    # enable iwd?
    
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "20.09"; # Did you read the comment?
  };
}
