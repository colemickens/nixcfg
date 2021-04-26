#!/usr/bin/env bash
set -euo pipefail

export AZURE_LOCATION="westus2"
export DATA_DISK_ID="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020data/providers/Microsoft.Compute/disks/datadisk"
export AZURE_DISK_ATTR="../..#images.azdev"
export AZURE_IMAGE_GROUP="azdev2020img"
export AZURE_IMAGE_NAME="azdevimg.vhd"

export AZURE_MACHINE_GROUP="azdev"
export AZURE_MACHINE_NAME="azdev"

if [[ "${1}" == "small" ]]; then
  export AZURE_VM_SIZE="Standard_D4as_v4"
  export AZURE_VM_OS_DISK_SIZE="128" # this can be larger than the sku allows, since we use a non-ephemeral disk
  export AZURE_STORAGE_SKU="Premium_LRS"
  export AZURE_EPHEMERAL_DISK="false"
  export AZURE_ACCEL_NIC="false"
elif [[ "${1}" == "large" ]]; then
  ## big size, boost, expensive, for intense dev seshs brah (ew, forgive me)
  export AZURE_VM_SIZE="Standard_D16as_v4"
  export AZURE_EPHEMERAL_DISK="true"
  export AZURE_ACCEL_NIC="true"
fi

export AZURE_SSH="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== cardno:000607126708"

NIXOS_AZURE="/home/cole/code/nixos-azure"
nix shell "${NIXOS_AZURE}#azutil" -c "deploy-vm"

# plex mostly wants to talk to itself on 32400...
# and I access nginx mostly just through tailscale esp since it's unauth'd
az network nsg rule create --resource-group "${AZURE_MACHINE_GROUP}" --nsg-name "azdevNSG" --name "allow_plex"  --protocol tcp --priority 1012 --destination-port-range 32400
