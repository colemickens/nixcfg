{ pkgs, ... }:

{
  config = {
    virtualisation.libvirtd = {
      enable = true;
    };
    
    # TODO: force myself to learn qemu
    # libvirt seems dead-ish bc of rh+k8s

    # TODO: how does usb redirection work with libvirt?

    # environment.systemPackages = with pkgs; [
    #   bridge-utils
    #   virtviewer
    #   virtmanager
    #   spice-gtk
    # ];
    security.wrappers.spice-client-glib-usb-acl-helper.source =
      "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  };
}

