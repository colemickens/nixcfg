#!/usr/bin/env bash
set -euo pipefail
set -x

# notes:
# https://lists.debian.org/debian-live/2017/05/msg00053.html
# except that tails fucks with debian-live
# it's kinda all garbage

rm -rf ~/.cache/ktails

# workdir
out="$(mktemp -d)"
img="$HOME/downloads/tails-amd64-4.19-img/tails-amd64-4.19.img"
#img="$HOME/downloads/tails-amd64-4.19-iso/tails-amd64-4.19.iso"

# outputs
CACHE="${KTAILS_CACHE:-"${HOME}/.cache/ktails"}"
mkdir -p "${CACHE}"
KERNEL="${CACHE}/ktails.vmlinuz"
INITRD="${CACHE}/ktails.initrd.gz"

############################

if [[ ! -f $KERNEL || ! -f $INITRD ]]; then
    7z x -o"${out}/" "${img}" \
    live/filesystem.squashfs live/initrd.img live/vmlinuz >/dev/null

    file "${out}/live/filesystem.squashfs"
    file "${out}/live/initrd.img"

    # cpio the squashfs on the end of the initrd
    echo 'live/filesystem.squashfs' \
    | cpio -o -H newc -D "${out}" \
        >> "${out}/live/initrd.img"

    # mv them into the cached location for future
    mv "${out}/live/vmlinuz" "${KERNEL}"
    mv "${out}/live/initrd.img" "${INITRD}"
fi

# in case of memory pressure
#bash
rm -rf "${out}"

# IMG
CMDLINE=""
CMDLINE="${CMDLINE} boot=live config"
#CMDLINE="${CMDLINE} live-media=removable nopersistence noprompt"
CMDLINE="${CMDLINE} live-media nopersistence noprompt"
CMDLINE="${CMDLINE} timezone=Etc/UTC noautologin module=Tails"
CMDLINE="${CMDLINE} slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1"
#CMDLINE="${CMDLINE} init_on_free=1 mds=full,nosmt quiet"
CMDLINE="${CMDLINE} init_on_free=1 mds=full,nosmt "
CMDLINE="${CMDLINE} plainroot root=/live/filesystem.squashfs toram"

# img
# initrd=/live/initrd.img boot=live config
# live-media=removable nopersistence noprompt
# timezone=Etc/UTC splash noautologin module=Tails
# slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1
# init_on_free=1 mds=full,nosmt  quiet

if [[ "${1:-""}" == "qemu" ]]; then
  qemu-system-x86_64 \
    -m 8192m \
    -kernel "${KERNEL}" \
    -initrd "${INITRD}" \
    -append "${CMDLINE}"

  exit 0
fi

sudo kexec --load --initrd "${INITRD}" --command-line "${CMDLINE}" "${KERNEL}"
sync && sudo sync
read -p "Press enter to continue"
sudo kexec --reset-vga --exec
