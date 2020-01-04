#!/usr/bin/env bash
set -euo pipefail
set -x

source ./common.sh
group="${group}-instance"

vm_size="Standard_D2s_v3";  os_size=15;
vm_size="Standard_D48s_v3"; os_size=1024; # bigger sku for building and auto-shutdown

az group create --location "westus2" --name "${group}"

group_id="$(az group show --name "${group}" -o tsv --query "[id]")"
az identity create --name "${group}-identity" --resource-group "${group}"
identity_id="$(az identity show --name "${group}-identity" --resource-group "${group}" -o tsv --query "[id]")"
principal_id="$(az identity show --name "${group}-identity" --resource-group "${group}" -o tsv --query "[principalId]")"
until az role assignment create --assignee "${principal_id}" --role "Owner" --scope "${group_id}"; do sleep 1; done

az vm create \
  --name "${group}-vm" \
  --resource-group "${group}" \
  --assign-identity "${identity_id}" \
  --size "${vm_size}" \
  --os-disk-size-gb "${os_size}" \
  --image "${1:-"${img_name}"}" \
  --admin-username "${USER}" \
  --location "westus2" \
  --storage-sku "Premium_LRS" \
  --ssh-key-values "$(ssh-add -L)"

