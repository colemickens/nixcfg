{ config, pkgs, lib, modulesPath, ... }:

let
  hn = "installer";

  cm-nixos-prep = pkgs.writeShellScriptBin "cm-nixos-prep" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    luksname="$1"
    newhostname="$2"
    pool="''${newhostname}pool"
    sudo zpool create \
      -O compression=zstd \
      -O mountpoint=none \
      -O xattr=sa \
      -O acltype=posixacl \
      -o autotrim=on \
      $pool \
      /dev/mapper/$luksname
    sudo zfs create -o mountpoint=legacy $pool/root
    sudo zfs create -o mountpoint=legacy $pool/nix
    sudo zfs create -o mountpoint=legacy $pool/home
    sudo zfs create -o mountpoint=legacy $pool/games
    sudo zfs create -o mountpoint=legacy $pool/data
  '';
  cm-nixos-mount = pkgs.writeShellScriptBin "cm-nixos-mount" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    newhostname="$1"
    pool="''${newhostname}pool";
    mnt="/mnt-$newhostname"

    sudo umount $mnt/efi/EFI/Linux || true
    sudo umount $mnt/efi/EFI/nixos || true
    sudo umount $mnt/boot || true
    sudo umount $mnt/efi || true
    sudo umount $mnt/nix || true
    sudo umount $mnt/home || true
    sudo umount $mnt/mnt/data || true
    sudo umount $mnt/mnt/games || true
    sudo umount $mnt || true
    if [[ "''${2:-}" == "umount" ]]; then
      exit
    fi
    sudo zpool export $pool || true

    sudo zpool import $pool
    sudo mkdir -p $mnt
    sudo mount -t zfs $pool/root $mnt
    sudo mkdir -p $mnt/{boot,efi,nix,home,mnt,mnt/data,mnt/games}
    sudo mount -t zfs $pool/nix $mnt/nix
    sudo mount -t zfs $pool/home $mnt/home
    sudo mount -t zfs $pool/data $mnt/mnt/data
    sudo mount -t zfs $pool/games $mnt/mnt/games

    sudo mount /dev/disk/by-partlabel/$newhostname-boot $mnt/boot
    sudo mount /dev/disk/by-partlabel/esp $mnt/efi

    sudo mkdir -p $mnt/efi/EFI/{Linux,nixos}
    sudo mkdir -p $mnt/boot/EFI/{Linux,nixos}
    sudo mount -o bind $mnt/boot/EFI/Linux $mnt/efi/EFI/Linux
    sudo mount -o bind $mnt/boot/EFI/nixos $mnt/efi/EFI/nixos
  '';
  cm-nixos-install = pkgs.writeShellScriptBin "cm-nixos-install" ''
    #!/usr/bin/env bash
    set -x
    set -euo pipefail
    newhostname="$1"
    system="$2"
    store="/mnt-$newhostname"
    sudo nix build -j0 \
      --store "$store" \
      --no-link \
      --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org' \
      --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4=' \
      $system
    
    sudo nixos-install \
      --no-root-passwd \
      --no-channel-copy \
      --system $system \
      --root "$store"
  '';
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    ../../profiles/core.nix
    ../../profiles/interactive.nix
  ];

  config = {
    ## <tailscale auto-login-qr>
    services.tailscale.enable = true;
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        echo "trying to connect to tailscale" &>2
        sudo tailscale login --qr
      )
    '';
    ## </tailscale auto-login-qr>

    environment.systemPackages = [
      cm-nixos-prep
      cm-nixos-mount
      cm-nixos-install

      pkgs.sbctl
    ];

    system.stateVersion = "23.11";

    services.getty.autologinUser = lib.mkForce "cole";

    boot.swraid.enable = lib.mkForce false;

    # TODO: remove when not debugging:
    # isoImage.squashfsCompression = null;

    nixpkgs.hostPlatform.system = "x86_64-linux";
    networking.hostName = hn;

    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.fwupd.enable = lib.mkForce false;

    # BUG not sure if this works, at one point it was claimed it didn't...
    boot.initrd.systemd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}





