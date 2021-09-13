{ pkgs, lib, config, inputs, ... }:
let
  hostname = "pinebook";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/libvirt.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/desktop-sway-unstable.nix

    "${inputs.wip-pinebook-pro}/pinebook_pro.nix"
  ];

  config = {
    system.stateVersion = "21.05";
    #nixpkgs.config.allowUnfree = true;

    hardware.usbWwan.enable = true;

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 2;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      (pkgs.writeScriptBin "pinebook-fix-sound" ''
        export NIX_PATH="nixpkgs=${toString inputs.nixpkgs}"
        ${toString inputs.wip-pinebook-pro}/sound/reset-sound.rb
      '')
    ];

    # ignore unfortunately placed power key
    # TODO: 3s-press or fn-power for shutdown
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    fileSystems = {
      "/" =     {
        device = "/dev/disk/by-partlabel/nixos";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
      };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      # we use Tow-Boot now:
      loader.grub.enable = false;
      loader.generic-extlinux-compatible.enable = true;
      
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
