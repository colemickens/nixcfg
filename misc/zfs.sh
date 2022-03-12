# zfs notes

# zfs create -o mountpoint=none <root>
# zfs create -o mountpoint=legacy compression=zstd ... <root>/<fs>
 
# zfs list -o name,compression,xattr,acltype,relatime,atime,com.sun:auto-snapshot
# sudo zfs set com.sun:auto-snapshot=true <pool>/<fs>
