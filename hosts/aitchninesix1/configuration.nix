{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  # eth_ip = "192.168.162.69/16";
  kernel = pkgs.callPackage ./kernel.nix { };
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
  hn = "aitchninesix1";

  krnl = config.boot.kernelPackages.kernel;
in
{
  imports = [
    ../rockfiveb1/unfree.nix
    ../../profiles/user.nix
    ../../mixins/common.nix
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
    # ../../mixins/iwd-networks.nix
  ]
  ++ inputs.tow-boot-radxa-rock5b.nixosModules
  ;
  config = {
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
    ];

    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${hn}-nixos";
      };
    };

    # system.build.sdImageX = (mkSpecialisation).config.system.build.sdImage;

    nixcfg.common = {
      useZfs = false;
      defaultKernel = false;
      defaultNetworking = false;
      sysdBoot = false;
    };

    system.build.installFiles = (
      let
        closureInfo = pkgs.closureInfo { rootPaths = config.system.build.toplevel; };
      in
      pkgs.runCommand "installFiles-${hn}" { } ''
        set -x
        mkdir $out
        mkdir $out/boot
        mkdir $out/root
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -d $out/boot/ -c "${config.system.build.toplevel}"
      
        cp -a "${closureInfo}/registration" "$out/root/nix-path-registration"
        echo "${config.system.build.toplevel.outPath}" > "$out/root/toplevel"
      ''
    ).out;
    boot.postBootCommands = ''
      if [[ -f /nix-path-registration ]]; then
        ${config.nix.package}/bin/nix-store --load-db < /nix-path-registration

        touch /etc/NIXOS
        ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
        
        rm -f /nix-path-registration
      fi
    '';


    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build = rec {
      mbr_disk_id = "888885b1";
    };

    boot.kernelPackages = kernelPackages;
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible = {
      enable = true;
    };

    hardware.deviceTree.name = "rockchip/rk3588-nvr-demo-v10-android.dtb";

    tow-boot = {
      enable = true;
      autoUpdate = false;
      device = "radxa-rock5b";
      config = {
        device.identifier = lib.mkForce "rockchip-rk3588-nvr-demo-v10";
        Tow-Boot = {
          defconfig = lib.mkForce "rk3588_defconfig";
          config = [
            (helpers: with helpers; {
              # DEFAULT_DEVICE_TREE = "rk3558-nvr-demo-v10-android";
            })
          ];
        };
      };
    };
  };
}