{ writeShellScriptBin }:
{
  cm-nixos-prep = writeShellScriptBin "cm-nixos-prep" ''
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
  cm-nixos-mount = writeShellScriptBin "cm-nixos-mount" ''
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

    sudo mkdir -p $mnt/efi/EFI/{loader/entries,nixos}
    sudo mkdir -p $mnt/boot/EFI/{loader/entries,nixos}
    sudo mount -o bind $mnt/boot/EFI/loader/entries $mnt/efi/EFI/loader/entries
    sudo mount -o bind $mnt/boot/EFI/nixos $mnt/efi/EFI/nixos
  '';
  cm-nixos-install = writeShellScriptBin "cm-nixos-install" ''
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
}
