{ pkgs, config, inputs, ... }:

let
  hostname = "pinephone";
in
{
  imports = [
    # avoid bringing in too much baggage for now:
    # ../../profiles/phone.nix
    
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos-pinephone}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
      # build: mobileNixos.outputs.diskImage (??)

      system.build.mobileNixos = config.mobile;
      
      documentation.enable = false;
      documentation.doc.enable = false;
      documentation.dev.enable = false;
      documentation.info.enable = false;
      documentation.nixos.enable = false;
      
      # if we have to `mobile.enable=false` then I guess we need this?
      # fileSystems = {
      #   "/" = { fsType = "ext4"; device = "/dev/sda1"; };
      # };
      # boot.loader.grub.enable = false;
      # boot.loader.generic-extlinux-compatible.enable = true;

      mobile = {
        # enable = false;
        # boot.stage-1.enable = true;
        boot.stage-1.kernel.useNixOSKernel = true;
      };
      boot.kernelPackages = pkgs.linuxPackages_latest;
      
      hardware.deviceTree.overlays = [
        {
          name = "pinephone-emmc-vccq-mod";
          dtsFile = ./dts-pinephone-emmc-vccq-mod.dts;
        }
      ];

      networking.hostName = hostname;
  };
}
