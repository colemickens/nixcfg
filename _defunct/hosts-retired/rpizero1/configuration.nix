{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizero1";

  rpiz2 = inputs.self.nixosConfigurations.rpizerotwo2;
  build = rpiz2.config.system.build.towbootBuild;
  pl = build.config.Tow-Boot.outputs.diskImage;
in
{
  imports = [
    ../rpi-bcm2835.nix
    "${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"

    ../../mixins/netboot-proxy.nix

    ../../profiles/user-cole.nix
    ../../mixins/common.nix
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
    ../../mixins/wpa-slim.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    
    nixcfg.common.useZfs = false;
    # nixcfg.common.defaultNetworking = false;
    # networking.useDHCP = true;

    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      supportedFilesystems = lib.mkForce [ "vfat" "nfs" ]; # so we can include profiles/base without pulling in zfs
      # TODO: it might be -just- libcomposite now, no g_hid?
      initrd.availableKernelModules = [ "dwc2" "libcomposite" ];
      kernelModules = [ "dwc2" "libcomposite" ];
      loader.raspberryPi.version = 0;
      loader.raspberryPi.firmwareConfig =  ''
        dtoverlay=dwc2
      '';
    };
  };
}
