{ pkgs, ... }:

{
  config = {
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemuRunAsRoot = false;
    };

    networking.bridges."virbr0".interfaces = [ "" ];

    virtualisation.spiceUSBRedirection.enable = true;
    #security.wrappers.spice-client-glib-usb-acl-helper.source =
    #  "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        virt-manager
        virt-viewer
      ];
    };
  };
}

