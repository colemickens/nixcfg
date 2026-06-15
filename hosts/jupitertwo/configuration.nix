{ pkgs, inputs, ... }:

let
  hn = "jupitertwo";
in
{
  imports = [
    #../../profiles/interactive.nix
    ../../profiles/core.nix
    ../../mixins/common.nix

    #inputs.determinate.nixosModules.default

    "${inputs.nixos-hardware-k3}/spacemit/k3-pico-itx"
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";
    system.stateVersion = "26.05";

    time.timeZone = "America/Chicago";

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";
    nixcfg.common.wifiWorkaround = true;

    services.tailscale.useRoutingFeatures = "server";

    systemd.network.enable = true;

    fileSystems = {
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/root";
        neededForBoot = true;
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/boot";
        neededForBoot = true;
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/swap"; } ];
  };
}
