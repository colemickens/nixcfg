{ config, lib, pkgs, ... }:

{
  config = {
    virtualisation.libvirtd = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      virtviewer
      virtmanager
      spice-gtk
    ];
    security.wrappers.spice-client-glib-usb-acl-helper.source =
      "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  };
}

