{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  # eth_ip = "192.168.162.69/16";
  kernel = pkgs.callPackage ./kernel.nix { };
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
  hn = "rockfiveb1";
in
{
  imports = [
    ./unfree.nix

    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
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

    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partuuid/${hn}-boot";
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
    };

    system.build.installer = (
      let
        closureInfo = pkgs.closureInfo { rootPaths = config.system.build.toplevel; };
      in
      pkgs.runCommand "make-installer-${hn}" { } ''
        set -x
        mkdir $out
        mkdir $out/boot
        mkdir $out/root
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -d $out/boot/ -c "${config.system.build.toplevel}"
      
        cp -a "${closureInfo}/registration" "$out/root/nix-path-registration"
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
    
    # install script
    system.build.installScript = ''
      # new gpt
      # new part boot
      # new part root
      # format boot
      # rsync $installer/boot
      # rsync $installer/root
      # nix copy --to --no-check-sigs
    '';

    networking.hostName = hn;
    system.stateVersion = "21.11";
    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      mbr_disk_id = "888885b1";
    };

    boot.kernelPackages = kernelPackages;
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible = {
      enable = true;
    };

    tow-boot.enable = true;
    tow-boot.autoUpdate = false;
    tow-boot.device = "radxa-rock5b";
    # configuration.config.Tow-Boot = {
    tow-boot.config = ({
      diskImage.mbr.diskID = config.system.build.mbr_disk_id;
      # useDefaultPatches = false;
      # withLogo = false;
    });
  };
}
