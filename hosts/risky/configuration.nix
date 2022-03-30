{ pkgs, modulesPath, inputs, config, ... }:

{
  imports = [
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    
    # the visionfive module pulls in the nixos-riscv64 overlay automatically:
    "${inputs.riscv64}/nixos/visionfive.nix"
  ];

  config = {
    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      binutils
      usbutils
    ];

    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
        generic-extlinux-compatible.configurationLimit = 3;
      };
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelModules = config.boot.initrd.availableKernelModules;
    };

    # TODO: move some more of this to common?
    networking = {
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

  };
}
