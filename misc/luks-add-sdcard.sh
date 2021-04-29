
# document how to add a key to the front of an sd card
# and then configure nixos to try that with luks

exit 0

# step 1: create key + enroll
dd if=/dev/urandom of=/tmp/hdd.key bs=4096 count=1
cryptsetup luksAddKey /dev/disk/by-partlabel/newluks /tmp/hdd.key

# step 2: put on front of removable storage
dd if=/tmp/hdd.key of=/dev/disk/by-id/mmc-EB1QT_0xa5f25355
