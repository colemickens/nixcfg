{ pkgs, ... }:

{
  config = {
    security.polkit.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.runAsRoot = false;
      extraConfig = ''
        unix_sock_group = "libvirtd"
      '';
    };
  };
}
