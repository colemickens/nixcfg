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

  image_id="$(nix shell ~/code/nixos-azure#azutil --command upload-vhd /tmp/azmail)"
fi

image_id="$(az image show -g "${IMAGE_GROUP}" -n "${IMAGE_NAME}" -o tsv --query '[id]')"

az group create -n "${MACHINE_GROUP}" -l "${AZURE_LOCATION}"

args=(
  --name "${MACHINE_NAME}"
  --resource-group "${MACHINE_GROUP}"
  --size "${AZURE_VM_SIZE}"
  --image "${image_id}"
  --attach-data-disks "${DATA_DISK_ID}"
  --admin-username "azureuser"
  --location "${AZURE_LOCATION}"
  --ssh-key-values "$(ssh-add -L | head -1)"
  --os-disk-size-gb "${AZURE_VM_OS_DISK_SIZE}"
  --storage-sku "${AZURE_STORAGE_SKU}"
  --public-ip-address-dns-name "${MACHINE_NAME}"
  --ephemeral-os-disk "${AZURE_EPHEMERAL_DISK}"
)

if [[ "${AZURE_PUBLIC_IP:-""}" != "" ]]; then
  args=("${args[@]}" "--public-ip-address" "${AZURE_PUBLIC_IP}")
fi

if [[ "${AZURE_ACCEL_NIC}" == "true" ]]; then
  args=("${args[@]}" "--accelerated-networking")
fi

az vm create "${args[@]}"
