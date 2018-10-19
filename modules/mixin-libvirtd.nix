{ ... }:

{
  services.libvirt = {
    enable = true;
  };
  environment.systemPackages = [
    virtviewer virt-manager
  ];
}

