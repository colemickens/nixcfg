#!/usr/bin/env bash
set -x
set -euo pipefail

export AZURE_LOCATION="westus2"
export AZURE_VM_SIZE="Standard_D64s_v3"
export AZURE_VM_SIZE="Standard_F64s_v2"
export AZURE_VM_SIZE="Standard_F72s_v2"
export AZURE_VM_SIZE="Standard_F8s_v2"
export AZURE_VM_OS_DISK_SIZE="100"

# uncomment to use a pre-existing image
# instead of building and uploading a new one

#image_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020nov/providers/Microsoft.Compute/images/21.03.20201101.dirty.vhd"

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
  (cd ../..; nix flake update --update-input nixos-azure)

  #upstream="github:colemickens/nixos-azure"
  upstream="/home/cole/code/nixos-azure"

  # build the VHD
  nix build "../..#images.azdev" --out-link /tmp/azdev

  # upload the VHD
  export AZURE_GROUP="azdev2020nov"
  if [[ "${image_id:-""}" == "" ]]; then
    image_id="$(set -euo pipefail; \
      nix shell "${upstream}" --command \
        azutil upload /tmp/azdev)"
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
    --os-disk-size-gb "128" \
    --public-ip-address-dns-name "${deploy}" \
    --ephemeral-os-disk true

  az vm show -g "${AZURE_GROUP}" -n "${AZURE_GROUP}"

  # unneeded with auto dns label
  #ip="$(az vm list-ip-addresses -n "${name}" -g "${name}" -o tsv \
  #  --query '[0].virtualMachine.network.publicIpAddresses[0].ipAddress')"

  host="${AZURE_GROUP}.${AZURE_LOCATION}.cloudapp.azure.com"

  # TODO: probably need to remove old entries
  # for the given hostname:
  ssh-keyscan -H "${host}" >> ~/.ssh/known_hosts
  export REMOTE="cole@${host}"
  # OPTION 2: use nixus to deploy azdev config
  # update the ip for nixus/azdev
  # nix-build nixus/azdev
  # run nixus/azdev->deploy
}



time deploy
