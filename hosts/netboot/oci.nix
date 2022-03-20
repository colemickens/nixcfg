{ config, pkgs, modulesPath, inputs, ... }: 

# most or all of this is borrowed from:
# https://github.com/NixOS/nixpkgs/pull/119856/files

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ../../mixins/common.nix
  ];
  config = {
    /* <coles additions> */
    
    # TODO: do something to fetch the hostname from IMDS on first boot
    # TODO: talk to graham and see if he has a service for first-boot provisioning
    # type stuff in nixos... (partitioning, etc)

    /* </coles additions> */

    # TODO: custom, slim, compressed kernel for OCI?

    boot = {
      kernelParams = [
        "nvme.shutdown_timeout=10"
        "nvme_core.shutdown_timeout=10"
        "libiscsi.debug_libiscsi_eh=1"
        "crash_kexec_post_notifiers"

        "console=tty1"           # VNC console
        "console=ttyS0"          # x86_64-linux
        "console=ttyAMA0,115200" # aarch64-linux
      ];
    };

    networking.timeServers = [ "169.254.169.254" ];
  };
}
