{ pkgs, tconfig, ... }:

# TODO: maybe this just pulls the tow-boot config
# and takes a ref to the tbBuilder and uses it?

let
  top = tconfig.system.build.toplevel;
  target = tconfig.networking.hostName;
  
  tb_rpi64 = tconfig.system.build.towbootBuild;
  tb_rpi64_sd = tb_rpi64.config.Tow-Boot.outputs.diskImage;

  boot = tconfig.fileSystems.${"/boot"}.device;
  firm = tconfig.fileSystems.${"/boot/firmware"}.device;

  hasMount = pth: builtins.hasAttr pth tconfig.fileSystems;
  fsDev = pth: if hasMount pth then tconfig.fileSystems.${pth}.device else "";
  fsType = pth: if hasMount pth then tconfig.fileSystems.${pth}.fsType else "";

  mbr_disk_id = tconfig.system.build.mbr_disk_id;

  imnt = "/mnt-${target}";

  # API: tow-boot path/disk-id?

  gen = pth: ''
    if [[ "${fsDev pth}" != "" ]]; then
      sudo mkdir -p "${imnt}${pth}"
      sudo mount -t "${fsType pth}" "${fsDev pth}" "${imnt}${pth}"
    fi
  '';
  installer = pkgs.writeShellScriptBin "x-${target}"
    (
      ''
        set -x
        set -euo pipefail
        
        function unmount1() {
          sudo umount \
            "/mnt-${target}/boot/firmware" \
            "/mnt-${target}/boot" \
            "/mnt-${target}/home" \
            "/mnt-${target}/persist" \
            "/mnt-${target}/nix" \
            "/mnt-${target}" \
            "${fsDev "/boot/firmware"}" \
            "${fsDev "/boot"}" \
            "${fsDev "/"}" \
              || true
          sudo zpool export "$(echo "${fsDev "/"}" | cut -d '/' -f1)" || true
        }
        function cleanup() {
          unmount1
          printf "::== exitting rpi-inst" >/dev/stderr
        }

        verb="''${1-"update"}"; shift
        if [[ "$verb" != "mount" ]]; then
          trap cleanup EXIT
        fi
        
        # TODO: this presumes the tow-boot partition size still...

        unmount1
        if [[ "$verb" == "prep"* ]]; then
          target="$1"; shift
        
          sudo "${pkgs.util-linux}/bin/wipefs" -a "$target"
          
          sudo ${pkgs.parted}/bin/parted --script -a optimal -- "$target" \
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
          sudo ${pkgs.parted}/bin/partprobe
          sleep 1
        
          sudo mkfs.vfat -F32 "${boot}"
          if [[ "$verb" != "preptowboot" ]]; then
            # use mbr_id for this because we're not... totally sure where it is
            sudo mkfs.ext4 "/dev/disk/by-partuuid/${mbr_disk_id}-03"
            sudo mkswap -f "/dev/disk/by-partuuid/${mbr_disk_id}-04"
          fi
        fi
        
        if [[ "$verb" == "prep"* ]]; then
          sudo dd \
            if="${tb_rpi64_sd}" \
            of="${firm}" \
            bs=512 skip=2048 count=65536 \
            conv=sync,nocreat
        fi
        
        if [[ "${fsType "/"}" == "zfs" ]]; then
          rootfspool="$(echo "${fsDev "/"}" | cut -d '/' -f 1)"
          sudo zpool import -f
          sudo zpool import -f "''${rootfspool}"
        fi
        
        ${gen "/"}
        # ''${gen "/nix"}
        # ''${gen "/home"}
        # ''${gen "/persist"}

        readlink -f "${boot}"
        sudo mkdir -p "${imnt}/boot";          sudo mount "${boot}" "${imnt}/boot"
        sudo mkdir -p "${imnt}/boot/firmware"; sudo mount "${firm}" "${imnt}/boot/firmware"
        
        sudo rm -f "${imnt}/boot/extlinux/extlinux.conf"

        if [[ "$verb" == "prep"* || "$verb" == "update" ]]; then
          sudo nixos-install --root "${imnt}" --system "${top}" --no-root-passwd \
            || true # can fail from secrets
          sudo nixos-enter --root "${imnt}" --command "sudo ssh-keygen -A"
          sudo nixos-enter --root "${imnt}" --command "sudo tow-boot-update"
        fi

        
        printf "\n\n::== !! MOUNT :D\n\n" >/dev/stderr
        mount >/dev/stderr

        printf "\n\n::== !! BOOT :D\n\n" >/dev/stderr
        exa -al --tree --level 2 "${imnt}/boot" >/dev/stderr

        printf "\n\n::== !! EXTLINUX :D\n\n" >/dev/stderr
        sudo sync
        cat "${imnt}/boot/extlinux/extlinux.conf" >/dev/stderr

        printf "\n\n::== !! CONFIGTXT :D\n\n" >/dev/stderr
        sudo sync
        cat "${imnt}/boot/firmware/config.txt" >/dev/stderr
        
        printf "\n\n::== !! ALL DONE :D\n\n" >/dev/stderr
      ''
    );
in
installer
