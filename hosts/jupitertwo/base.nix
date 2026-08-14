{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  hn = "jupitertwo";
in
{
  imports = [
    ../../profiles/addon-riscv64-fixes.nix

    # ../../profiles/interactive.nix
    ../../profiles/core.nix
    ../../mixins/common.nix

    ../../mixins/bottom.nix
    ../../mixins/helix.nix
    ../../mixins/nushell.nix
    ../../mixins/zellij.nix

    ./extra.nix

    "${inputs.nixos-hardware}/spacemit/k3-pico-itx"
  ];

  #
  # nix build --narinfo-cache-negative-ttl 0 -j0 github:colemickens/nixcfg/9a8c9fa3#toplevels.jupitertwo --extra-experimental-features nix-command --extra-experimental-features flakes --option netrc-file /nix/var/determinate/netrc --extra-substituters 'https://cache.flakehub.com' --extra-trusted-public-keys 'cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y='
  #
  # nix-store -r $top --option narinfo-cache-negative-ttl 0 --option netrc-file /nix/var/determinate/netrc --extra-substituters 'https://cache.flakehub.com https://edge.cache.flakehub.com/' --extra-trusted-public-keys 'cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y='
  # sudo nix build --profile /nix/var/nix/profiles/system $top --extra-experimental-features nix-command --extra-experimental-features flakes
  # sudo $top/bin/switch-to-configuration switch
  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";
    system.stateVersion = "26.05";

    system.nixos-init.enable = true;
    system.tools.nixos-build-vms.enable = false;
    system.tools.nixos-enter.enable = false;
    system.tools.nixos-generate-config.enable = false;
    system.tools.nixos-install.enable = false;
    system.tools.nixos-option.enable = false;
    system.tools.nixos-rebuild.enable = false;
    system.tools.nixos-version.enable = false;

    environment.systemPackages = with pkgs; [
      # buildkite-agent (one instance of perl)
      github-act-runner
      ripgrep

      # other firmware/sdcard bits; prebuild for when HW arrives
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/edk2.nix" { })
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/fsbl.nix" { })
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/opensbi.nix" { })
      (pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/uboot.nix" { })
    ];

    time.timeZone = "America/Chicago";

    # <workarounds>
    services.fwupd.enable = lib.mkForce false;
    services.udisks2.enable = lib.mkForce false;
    # </workarounds>

    networking.hostName = hn;
    nixcfg.common.hostColor = "blue";
    nixcfg.common.wifiWorkaround = false;
    nixcfg.common.useZfs = false;

    networking.networkmanager.enable = true;
    networking.useDHCP = false;
    networking.dhcpcd.enable = false;

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
