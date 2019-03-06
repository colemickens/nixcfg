{...}:

let
  overlay = name: url:
    if builtins.pathExists "/home/cole/code/overlays/${name}"
    then (import "/home/cole/code/overlays/${name}")
    else (import (builtins.fetchTarball "${url}"));

  mkSystem = { nixpkgs, nixoscfg, system, localnixpkgs ? "/zzz", extraModules ? [] }:
    let
      importpath =
        if builtins.pathExists localnixpkgs
        then localnixpkgs
        else nixpkgs.pkgs;
      pkgs = import importpath {
        inherit system;
        inherit (machine.config.nixpkgs) config overlays;
      };
      extraModulesNew = extraModules ++ (
        if builtins.pathExists localnixpkgs
        then []
        else [
          ({config, ...}: {
            system.nixos.revision = nixpkgs.meta.revShort;
            system.nixos.versionSuffix = ".git.${nixpkgs.meta.revShort}";
          })
        ]
      );
      machine = import "${importpath}/nixos/lib/eval-config.nix" {
        inherit (pkgs) system;
        inherit pkgs;
        modules = [ nixoscfg ] ++ extraModulesNew;
      };
    in
      machine;

  # mkInstaller -> do we reference the system closure that we want to copy over? yas
  # do we require the user to acquire nixcfg?
  # can we do an install without having a nixpkgs or nixcfg cloned if we do nixos-install with a system
  # closure we copied? If so, we should take a direct reference to that closure which should get it included as well
  # and then we just need to include the script as part of the build the same way clever does. maybe. right?

  #stolen from github.com/cleverca22/nix-tests but better (or juts different)
  # mkInstallScript = {
  #   hostname,
  #   rootDevice,
  #   poolName,
  #   bootSize,
  #   swapSize,
  #   x ? "p",
  #   windowsSize ? 0 }:
  #   pkgs.writeScriptBin "justdoit-${hostname}" ''
  #     #!${pkgs.stdenv.shell}
  #     set -x
  #     set -e
  #     vgchange -a n
  #     wipefs -a ${rootDevice}
  #     dd if=/dev/zero of=${rootDevice} bs=512 count=10000
  #     sfdisk ${rootDevice} <<EOF
  #       label: gpt
  #       device: ${rootDevice}
  #       unit: sectors
  #       1 : size=${toString (2048 * bootSize)},             type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
  #       2 :                                                 type=CA7D7CCB-63ED-4C53-861C-1742536059CC
  #       ${if windowsSize > 0 then ''
  #         3 : size=${toString (2048 * 512)},                type=DE94BBA4-06D1-4D40-A16A-BFD50179D6AC
  #         4 : size=${toString (2048 * 128)},                type=E3C9E316-0B5C-4DB8-817D-F92DF00215AE
  #         5 : size=${toString (2048 * windowsSize * 1024)}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7
  #       '' else ""}
  #     EOF
  #     cryptsetup luksFormat ${rootDevice}${x}2
  #     cryptsetup open --type luks ${rootDevice}${x}2 root
  #     pvcreate /dev/mapper/root
  #     vgcreate ${poolName} /dev/mapper/root
  #     lvcreate -L ${toString swapSize} --name swap ${poolName}
  #     lvcreate -l '100%FREE' --name root ${poolName}
  #     export ROOT_DEVICE=/dev/${poolName}/root
  #     export SWAP_DEVICE=/dev/${poolName}/swap
  #     export NIXOS_BOOT=${rootDevice}${x}1
  #     mkdir -p /mnt
  #     mkfs.vfat $NIXOS_BOOT -n NIXOS_BOOT
  #     mkswap $SWAP_DEVICE -L NIXOS_SWAP
  #     zpool create -o ashift=12 -o altroot=/mnt -O compression=lz4 ${poolName} $ROOT_DEVICE
  #     zfs create -o mountpoint=legacy ${poolName}/root
  #     zfs create -o mountpoint=legacy ${poolName}/home
  #     zfs create -o mountpoint=legacy ${poolName}/nix
  #     swapon $SWAP_DEVICE
  #     mount -t zfs ${poolName}/root /mnt/
  #     mkdir /mnt/{home,nix,boot}
  #     mount -t zfs ${poolName}/home /mnt/home/
  #     mount -t zfs ${poolName}/nix /mnt/nix/
  #     mount $NIXOS_BOOT /mnt/boot/
  #     nixos-install
  #     umount /mnt/home /mnt/nix /mnt/boot /mnt
  #     zpool export ${poolName}
  #   '';
in
  {
    inherit overlay;
    inherit mkSystem;
    #inherit mkInstallScript;
  }
