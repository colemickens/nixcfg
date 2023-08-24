# zfs notes

## generic device creation


## backup device creation

```shell
sudo cryptsetup luksFormat --header ~/Sync/ORION_RAISIN/header.img /dev/sdc
sudo cryptsetup luksOpen --header ~/Sync/ORION_RAISIN/header.img /dev/sdc orionraisin

sudo zpool create -O mountpoint=none "orionraisinpool" /dev/mapper/orionraisin
```
