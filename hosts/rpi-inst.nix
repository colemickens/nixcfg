{ pkgs, target, tconfig, tow-boot, ... }:

# TODO: maybe this just pulls the tow-boot config
# and takes a ref to the tbBuilder and uses it?

let
  top = tconfig.system.build.toplevel;
  tb_rpi64 = tow-boot.aarch64-linux.raspberryPi-aarch64;
  tb_rpi64_sd = tb_rpi64.config.Tow-Boot.outputs.diskImage;

  root = tconfig.fileSystems.${"/"}.device;
  boot = tconfig.fileSystems.${"/boot"}.device;
  firm = tconfig.fileSystems.${"/boot/firmware"}.device;
  mbr_disk_id = tconfig.system.build.mbr_disk_id;
  
  imnt = "/mnt-${target}";

  # API: tow-boot path/disk-id?

  installer = pkgs.writeShellScriptBin "x-${target}"
    (
      ''
        set -x
        set -euo pipefail
        
        function unmount() {
          sudo umount \
            "/mnt-${target}/boot/firmware" \
            "/mnt-${target}/boot" \
            "/mnt-${target}" \
              || true
        }

        verb="''${1-"update"}"; shift
        if [[ "$verb" != "mount" ]]; then
          trap unmount EXIT
        fi
        
        # TODO: this presumes the tow-boot partition size still...

        unmount

        if [[ "$verb" == "prep" ]]; then
          target="$1"; shift
        
          sudo "${pkgs.util-linux}/bin/wipefs" -a "$target"
          
          sudo parted --script -a optimal -- "$target" \
            mklabel msdos \
            mkpart primary     "1MiB"    "33MiB" \
            mkpart primary    "33MiB"   "545MiB" \
            mkpart primary   "545MiB" "-2048MiB" \
            mkpart primary "-2048MiB" "-2048s"

          sudo sfdisk --disk-id "$target" "0x${mbr_disk_id}"

          sudo sfdisk --part-type "$target" 1 0x0C
          sudo sfdisk --part-type "$target" 2 0xEF
          sudo sfdisk --part-type "$target" 3 0x83
          sudo sfdisk --part-type "$target" 4 0x82
          
          sudo sync
          sudo partprobe
          sleep 1
        
          sudo mkfs.vfat -F32 "${boot}"
          # use mbr_id for this because we're not... totally sure where it is
          sudo mkfs.ext4 "/dev/disk/by-partuuid/${mbr_disk_id}-03"
          sudo mkswap -f "/dev/disk/by-partuuid/${mbr_disk_id}-04"
        fi
        
        if [[ "$verb" != "mount" ]]; then
          sudo dd \
            if="${tb_rpi64_sd}" \
            of="${firm}" \
            bs=512 skip=2048 count=65536 \
            conv=sync,nocreat
        fi
        
        if [[ "${target}" == "rpifour1" ]]; then
          sudo mkdir -p "${imnt}";               sudo mount "${root}" -t zfs "${imnt}"
          sudo mkdir -p "${imnt}/boot";          sudo mount "${boot}" "${imnt}/boot"
          sudo mkdir -p "${imnt}/boot/firmware"; sudo mount "${firm}" "${imnt}/boot/firmware"
        else
          sudo mkdir -p "${imnt}";               sudo mount "${root}" "${imnt}"
          sudo mkdir -p "${imnt}/boot";          sudo mount "${boot}" "${imnt}/boot"
          sudo mkdir -p "${imnt}/boot/firmware"; sudo mount "${firm}" "${imnt}/boot/firmware"
        fi

        if [[ "$verb" != "mount" ]]; then
          sudo nixos-install --root "${imnt}" --system "${top}" --no-root-passwd \
            || true # can fail from secrets
          sudo nixos-enter --root "${imnt}" --command "sudo ssh-keygen -A"
        fi
        sudo sync
      ''
    );
in
installer
