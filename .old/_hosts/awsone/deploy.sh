#!/usr/bin/env bash
set -x
set -euo pipefail

#export AZURE_GROUP="${AZURE_GROUP:-"$(printf '%x' "$(date '+%s')")"}"
export AZURE_GROUP="${1}"
export AZURE_VM_SIZE="${AZURE_VM_SIZE:-"Standard_E8s_v3"}"
export AZURE_LOCATION="${AZURE_LOCATION:-"westcentralus
"}"
export AZURE_PRICE="${AZURE_PRICE:-"-1"}"

#upstream="github:colemickens/nixos-azure"
upstream="/home/cole/code/nixos-azure"; (cd ../..; nix flake update --update-input nixos-azure)

image_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020nov/providers/Microsoft.Compute/images/21.03.20201231.7158b1e.vhd"
data_disk_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020data/providers/Microsoft.Compute/disks/datadisk"

if ! az disk show -n "${AZURE_GROUP}-disk" -g "${AZURE_GROUP}-data" &>/dev/null; then
  az group create -n "${AZURE_GROUP}-data" -l "${AZURE_LOCATION}"
  az disk create --name "${AZURE_GROUP}-disk" --resource-group "${AZURE_GROUP}-data" --size-gb 128 --location "${AZURE_LOCATION}"
  az group lock create --name "${AZURE_GROUP}-lock" --resource-group "${AZURE_GROUP}-data" --lock-type 'CanNotDelete'
fi

data_disk_id="$(az disk show -n "${AZURE_GROUP}-disk" -g "${AZURE_GROUP}-data" -o tsv --query '[id]')"

az group create -n "${AZURE_GROUP}-vm" -l "${AZURE_LOCATION}"
az vm create \
  --name "${AZURE_GROUP}-vm" \
  --resource-group "${AZURE_GROUP}-vm" \
  --size "${AZURE_VM_SIZE}" \
  --image "${image_id}" \
  --attach-data-disks "${data_disk_id}" \
  --admin-username "azureuser" \
  --location "${AZURE_LOCATION}" \
  --ssh-key-values "$(ssh-add -L | head -1)" \
  --os-disk-size-gb "128" \
  --public-ip-address-dns-name "${AZURE_GROUP}" \
  --priority 'Spot' --max-price "${AZURE_PRICE}" \
  --ephemeral-os-disk true \
  --accelerated-networking
