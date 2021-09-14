{ pkgs, lib, config, inputs, ... }:
let
  hostname = "pinebook";

  pinebook-fix-sound = (pkgs.writeScriptBin "pinebook-fix-sound" ''
    export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
    ${toString inputs.wip-pinebook-pro}/sound/reset-sound.rb
  '');
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/desktop-sway-unstable.nix

    "${inputs.wip-pinebook-pro}/pinebook_pro.nix"
  ];

  config = {
    system.stateVersion = "21.05";

    hardware.usbWwan.enable = true;

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 2;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      # TODO: run on boot (?)
      pinebook-fix-sound
    ];

    systemd.services.pinebook-fix-sound = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pinebook-fix-sound;
      };
      wantedBy = [ "multi-user.target" ];
    };

    # ignore unfortunately placed power key
    # TODO: 3s-press or fn-power for shutdown
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    fileSystems = {
      "/" =     {
        device = "/dev/disk/by-partlabel/nixos";
        #device = "/dev/disk/by-id/mmc-DA4064_0xe0291213-part2";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        #device = "/dev/disk/by-id/mmc-DA4064_0xe0291213-part1";
        fsType = "vfat";
      };
      # idk, empty? weird, scary, get rid of it
      # "/firmware" = {
      #   device = "/dev/disk/by-id/mmc-EB1QT_0x095f55ab-part1";
      #   fsType = "vfat";
      #   options = [ "ro" "nofail" ];
      # };
    };
    swapDevices = [];

    console.earlySetup = true; # luks

    boot = {
      # we use Tow-Boot now:
      loader.grub.enable = false;
      loader.generic-extlinux-compatible.enable = true;
      
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      kernelPatches = [{
        name = "pinebook-disable-dp";
        patch = ./pbp-disable-dp.patch;
      }];
      kernelParams = [
        # "cma=32M" # samueldr says so
        "mitigations=off"
        "console=ttyS2,1500000n8" "console=tty0"
      ]; 

      initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ "nvme" ];
    };

    networking = {
      hostId = "ef66d544";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 5900 22 ];
      networkmanager.enable = true;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
    };
  };
}
