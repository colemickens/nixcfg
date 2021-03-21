#!/usr/bin/env bash
set -x
set -euo pipefail

export AZURE_LOCATION="westus2"
#export AZURE_VM_SIZE="Standard_F72s_v2" export AZURE_VM_OS_DISK_SIZE="1024"; export AZURE_EPHEMERAL_DISK="true"
export AZURE_VM_SIZE="Standard_D4as_v4"; export AZURE_VM_OS_DISK_SIZE="128"; export AZURE_EPHEMERAL_DISK="false"

export AZURE_STORAGE_SKU="Premium_LRS"

### TODO: when the disk is not ephemeral, it is an HDD!!
# we should deploy an SSD at least when a small VM

# uncomment to use a pre-existing image
# instead of building and uploading a new one

image_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020nov/providers/Microsoft.Compute/images/azdev-21.03.20210129.711d6c9-b6807db8.vhd"

data_disk_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020data/providers/Microsoft.Compute/disks/datadisk"
# function create_disk() {
#   az group create -n 'azdev2020data' -l "${AZURE_LOCATION}"

#   az disk create \
#     --name 'datadisk' \
#     --resource-group 'azdev2020data' \
#     --size-gb 128 \
#     --location "${AZURE_LOCATION}"

#   az group lock create \
#     --name 'azdev2020datalock' \
#     --lock-type 'CanNotDelete' \
#     --resource-group 'azdev2020data'
# }
#

function deploy() {
  (cd ../..; nix flake update)

  # upload the VHD
  export AZURE_GROUP="azdev2020nov"
  if [[ "${image_id:-""}" == "" ]]; then
    # build the VHD
    nix build "../..#images.azdev" --out-link /tmp/azdev

    image_id="$(nix shell ~/code/nixos-azure#azutil --command upload-vhd /tmp/azdev)"
    echo "image_id=$image_id"
  fi

  # boot a VM
  export AZURE_GROUP="azdev2020vm1"
  export deploy="${AZURE_GROUP}"

  az group create -n "${deploy}" -l "${AZURE_LOCATION}"

  az vm create \
    --name "${deploy}" \
    --resource-group "${deploy}" \
    --size "${AZURE_VM_SIZE}" \
    --image "${image_id}" \
    --attach-data-disks "${data_disk_id}" \
    --admin-username "azureuser" \
    --location "${AZURE_LOCATION}" \
    --ssh-key-values "$(ssh-add -L | head -1)" \
    --os-disk-size-gb "${AZURE_VM_OS_DISK_SIZE}" \
    --storage-sku "${AZURE_STORAGE_SKU}" \
    --public-ip-address-dns-name "${deploy}" \
    --ephemeral-os-disk "${AZURE_EPHEMERAL_DISK}" \
    --accelerated-networking

  az vm show -g "${AZURE_GROUP}" -n "${AZURE_GROUP}"

  host="${AZURE_GROUP}.${AZURE_LOCATION}.cloudapp.azure.com"
}



time deploy
