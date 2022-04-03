{ pkgs, lib, inputs, config, ... }:

let
  hostname = "blueline";
in
{
  imports = [
    ../../profiles/phone.nix
      
    ./unfree.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "google-blueline";
    })
  ];

  config = {
    nixcfg.common.defaultKernel = false;
      
    system.stateVersion = "21.05";
    system.build.android-serial = "89WX0J2GL";
    
    virtualisation = {
      waydroid.enable = true;
      lxc.enable = true;
      lxc.lxcfs.enable = true;
      lxd.enable = true;
      lxd.zfsSupport = false;
    };

    boot.kernelParams = lib.mkAfter [ "loglevel=7" ];
    hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];

    # usb0 never appears with this disabled:
    mobile.boot.stage-1.networking.enable = true;

    networking.hostName = hostname;
    # networking.wireless.iwd.enable = true;
  };
}
