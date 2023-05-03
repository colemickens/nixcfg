{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../modules/other-arch-vm.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      inetutils
    ];
    services.buildVMs = {
      risky = {
        vmSystem = "riscv64-linux";
        vmpkgs = inputs.cmpkgs-cross-riscv64;
        smp = 32;
        mem = "128g";
        consoleListenPort = 9009;
        config = ({ config, pkgs, lib, ... }@inner: {
          imports = [
            ../profiles/core.nix
            ../profiles/addon-cross.nix
            ../modules/tailscale-autoconnect.nix
          ];
          config = {
            boot.kernelPackages = lib.mkForce inner.pkgs.linuxKernel.packages.linux_6_2;
            nixcfg.common = {
              defaultKernel = false;
              defaultNetworking = false;
              useZfs = false;
              addLegacyboot = false;
            };
            services.tailscale-autoconnect = {
              # enable = true;
              tokenFile = (pkgs.writeTextFile {
                name = "foo";
                text = "tskey-auth-kF9qxB1CNTRL-idvYSfaxfNEzo8pmCW9JKEK1STTbkZh9Z";
              }).outPath;
            };
            networking.hostName = "pktspot1riscv";
            # boot.initrd.systemd.enable = false;
            boot.initrd.systemd.emergencyAccess = true;
          };
        });
      };
    };
  };
}
