#!/usr/bin/env bash
set -x
set -euo pipefail

#export AZURE_VM_SIZE="Standard_F72s_v2" export AZURE_VM_OS_DISK_SIZE="1024"; export AZURE_EPHEMERAL_DISK="true"
# export AZURE_VM_OS_DISK_SIZE="128";
# export AZURE_EPHEMERAL_DISK="false"
# export AZURE_STORAGE_SKU="Premium_LRS"

# create pip:
#   az network public-ip create \
#     --static-ip \
#     -n "azmailpublicip" -g "azmaildata" -l "westus2"

# create disk:
#   az group create -n 'azdev2020data' -l "${AZURE_LOCATION}"
#   az disk create --name 'datadisk' --resource-group 'azdev2020data' --size-gb 128 --location "${AZURE_LOCATION}"
#   az group lock create --name 'azdev2020datalock' --lock-type 'CanNotDelete' --resource-group 'azdev2020data'

#(cd ../..; nix flake update)

# upload the VHD
if ! az image show -g "${IMAGE_GROUP}" -n "${IMAGE_NAME}" &>/dev/null; then
  # build the VHD
  nix build "${DISK_ATTR}" --out-link /tmp/${MACHINE_NAME}

  image_id="$(nix shell ~/code/nixos-azure#azutil --command upload-vhd /tmp/${MACHINE_NAME})"
fi

image_id="$(az image show -g "${IMAGE_GROUP}" -n "${IMAGE_NAME}" -o tsv --query '[id]')"

az group create -n "${MACHINE_GROUP}" -l "${AZURE_LOCATION}"

AZURE_SSH="${AZURE_SSH:-"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== cardno:000607126708"}"

args=(
  --name "${MACHINE_NAME}"
  --resource-group "${MACHINE_GROUP}"
  --size "${AZURE_VM_SIZE}"
  --image "${image_id}"
  --attach-data-disks "${DATA_DISK_ID}"
  --admin-username "azureuser"
  --location "${AZURE_LOCATION}"
  --ssh-key-values "${AZURE_SSH}"
  --os-disk-size-gb "${AZURE_VM_OS_DISK_SIZE}"
  --storage-sku "${AZURE_STORAGE_SKU}"
  --public-ip-address-dns-name "${MACHINE_NAME}"
  --ephemeral-os-disk "${AZURE_EPHEMERAL_DISK}"
)

if [[ "${AZURE_PUBLIC_IP:-""}" != "" ]]; then
  args=("${args[@]}" "--public-ip-address" "${AZURE_PUBLIC_IP}")
fi

if [[ "${AZURE_NSG:-""}" != "" ]]; then
  args=("${args[@]}" "--nsg" "${AZURE_NSG}")
fi

if [[ "${AZURE_ACCEL_NIC:-}" == "true" ]]; then
  args=("${args[@]}" "--accelerated-networking")
fi

az vm create "${args[@]}"
