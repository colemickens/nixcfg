{ config, pkgs, lib, ... }:

{
  config = {
    networking.networkmanager.plugins = lib.mkForce [];

    services.fwupd.enable = lib.mkForce false;
    services.udisks2.enable = lib.mkForce false;
    hardware.usbWwan.enable = lib.mkForce false;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    system.nixos.tags = [ "cross" ];

    # TODO: not sure about this one
    fonts.fontconfig.enable = false;
    
    nixpkgs.overlays = [
      (final: prev: {
        gnupg23 = prev.gnupg23.override { openldap = null; };
        # openfortivpn = null;
        # networkmanager-fortisslvpn = null;
      })
    ];
  };
}
