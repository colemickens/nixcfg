# zfs notes

## generic device creation


## backup device creation

```shell
sudo cryptsetup luksFormat --header ~/Sync/ORION_RAISIN/header.img /dev/sdc
sudo cryptsetup luksOpen --header ~/Sync/ORION_RAISIN/header.img /dev/sdc orionraisin

sudo zpool create -O mountpoint=none "orionraisinpool" /dev/mapper/orionraisin

sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl
  -o relatime=on orionraisinpool/backups/zeph/zephpool
```

