{ pkgs, inputs, ... }:

let
  hn = "slynux";
  pp = "slynux"; # ?
  swappart = "slynux-swap";
  asVm = false;
in
{
  imports = [
    ./unfree.nix
    ../../mixins/common.nix

    ../../mixins/github-actions-runners.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    # ../../mixins/rclone-googledrive-mounts.nix

    ../../profiles/interactive.nix
    (import ../../profiles/addon-clouddev.nix { hostname = "slynux.mickens.us"; })
    ../../profiles/addon-devtools.nix

    inputs.determinate-main.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    networking.hostName = hn;
    # https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/alacritty/Tango%20Adapted.yml
    # nixcfg.common.hostColor = "#00a2ff";
    nixcfg.common.hostColor = "blue";

    # jesus christ, nothing but a pain
    # zramSwap.enable = true;

    services.go2rtc = {
      enable = true;
      settings = {
        # api/webui = :1984
        streams = {
          webcam = "ffmpeg:device?video=/dev/video0&input_format=yuyv422&video_size=1920x1080#video=h264#hardware";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      qemu
    ];

    nix.gc = {
      automatic = true;
      persistent = true;
    };

    services.tailscale.useRoutingFeatures = "server";

    fileSystems = {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${pp}-boot";
      };
      "/" = {
        fsType = "zfs";
        device = "${pp}pool/root";
      };
      "/nix" = {
        fsType = "zfs";
        device = "${pp}pool/nix";
      };
      "/home" = {
        fsType = "zfs";
        device = "${pp}pool/home";
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/${swappart}"; } ];

    boot = {
      tmp = {
        useTmpfs = false; # this seems to not give enough RAM for a kernel build
        cleanOnBoot = true;
      };
      initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "ehci_pci"
        "uas"
      ];
      kernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "ehci_pci"
        "uas"
      ];
      initrd.luks.devices = {
        "nixos-luksroot" = {
          device = "/dev/disk/by-partlabel/${hn}-luksroot";
          allowDiscards = true;
          keyFile = "/lukskey";
        };
      };
      initrd.secrets."/lukskey" = pkgs.writeText "lukskey" "test";
    };
  };
}
