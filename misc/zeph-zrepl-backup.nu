#!/usr/bin/env nu

let ssd = "usb-Realtek_RTL9210_NVME_012345678903-0:0"
let hdr = "/home/cole/Sync/ORION_NVME_SSD/header.img"

let luksdev = "orion"
let backup_pool = "orionpool"

let pass = (prs show orion | complete | get stdout | str trim)

print -e "::: close backup pool"
do -i { sudo sync; sync }
do -i { sudo zpool export $backup_pool }
do -i { sudo cryptsetup luksClose $luksdev }

print -e "::: open backup pool"

echo $pass | sudo cryptsetup luksOpen --header $hdr $"/dev/disk/by-id/($ssd)" $luksdev -
sudo zpool import $backup_pool

print -e "::: trigger push_to_orion"
# TRIGGER ZREPL to copy
sudo zrepl signal wakeup 'push_to_orion'

# TODO: how to wait for replication to finish?

print -e ""
print -e "::: running, run these commands when it's done"
print -e $"sudo sync; sudo zpool export ($backup_pool); sudo cryptsetup luksClose ($luksdev)"

sudo zrepl status
