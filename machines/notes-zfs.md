# notes

see ./slynux/disk.sh !!! better options??

fdisk ...

zpool create -O mountpoint=none -R /mnt rpool /dev/sda2
zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl rpool/root
zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl -o atime=off rpool/nix
zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl rpool/var
zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl rpool/home

mount -t zfs rpool/root /mnt
mkdir /mnt/{nix,var,home,boot}
mount -t zfs rpool/home /mnt/home
mount -t zfs rpool/nix /mnt/nix
mount -t zfs rpool/var /mnt/var

mkfs.vfat -n BOOT /dev/sda1
mount /dev/disk/by-label/BOOT /mnt/boot

nixos-generate-config --root /mnt

# Edit /mnt/etc/nixos/configuration.nix and add the following line:

boot.supportedFilesystems = [ "zfs" ];
networking.hostId = "<random 8-digit hex string>"

nixos-install
