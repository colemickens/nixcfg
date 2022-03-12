{ pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/docker.nix
    ../../mixins/libvirt.nix
    ../../mixins/obs.nix
    ../../mixins/sshd.nix
    ../../mixins/v4l2loopback.nix
    ../../profiles/user.nix

    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"

    ../../profiles/interactive.nix
    ../../profiles/desktop-gnome.nix
  ];

  config = {
    # TODO move to devenv
    system.stateVersion = "20.03"; # Did you read the comment?
    #services.timesyncd.enable = true;
    documentation.nixos.enable = false;
    services.resolved.enable = false;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostId = "deadc0c0";
    networking.hostName = "demovm";

    # demovm options
    virtualisation.graphics = true;
    virtualisation.cores = 2;
    virtualisation.memorySize = 4096;
    #virtualisation.useSpice = true;
    #virtualisation.spicePort = 5930;
    services.openssh.enable = true;

    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = lib.mkForce true;
  };
}
