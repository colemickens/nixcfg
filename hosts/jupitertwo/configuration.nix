{ pkgs, lib, inputs, ... }:

let
  hn = "jupitertwo";
in
{
  imports = [
    ../../profiles/addon-riscv64-fixes.nix

    # ../../profiles/interactive.nix
    ../../profiles/core.nix
    ../../mixins/common.nix

    #inputs.determinate.nixosModules.default

    "${inputs.nixos-hardware}/spacemit/k3-pico-itx"
  ];

  # nix build github:colemickens/nixcfg#toplevels.jupitertwo --extra-experimental-features nix-command --extra-experimental-features flakes --option netrc-file /nix/var/determinate/netrc --extra-substituters 'https://cache.flakehub.com' --extra-trusted-public-keys 'cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y='
  # nix-store -r  --option netrc-file /nix/var/determinate/netrc --extra-substituters 'https://cache.flakehub.com' --extra-trusted-public-keys 'cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y='
  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";
    system.stateVersion = "26.05";

    nix.settings = {
      keep-derivations = true; # this is the default (?)
      builders-use-substitutes = true;
      cores = lib.mkDefault 0;
      max-jobs = lib.mkDefault "auto";
      use-xdg-base-directories = true;
      extra-trusted-public-keys = [
        "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
        "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
        "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
        "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
        "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
        "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
      ];
      extra-substituters = [
        "https://colemickens.cachix.org"
        "https://cache.flakehub.com"
      ];
      extra-trusted-substituters = [
        "https://colemickens.cachix.org"
        "https://cache.flakehub.com"
      ];
      netrc-file = "/nix/var/determinate/netrc";
      trusted-users = [
        "@wheel"
        "cole"
        "root"
      ];
    };

    environment.systemPackages = with pkgs; [
      buildkite-agent

      # other firmware/sdcard bits; prebuild for when HW arrives
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/edk2.nix" {})
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/fsbl.nix" {})
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/opensbi.nix" {})
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/uboot.nix" {})
    ];

    time.timeZone = "America/Chicago";

    # <workarounds>
    services.fwupd.enable = lib.mkForce false;
    services.udisks2.enable = lib.mkForce false;
    # </workarounds>

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";
    nixcfg.common.wifiWorkaround = false;

    services.tailscale.useRoutingFeatures = "server";

    systemd.network.enable = true;

    fileSystems = {
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/nixos-rootfs";
        neededForBoot = true;
      };
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/ESP";
        neededForBoot = true;
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/swap"; } ];
  };
}
