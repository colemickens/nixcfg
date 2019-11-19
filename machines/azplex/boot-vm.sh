#!/usr/bin/env bash
set -euo pipefail
set -x

source ./common.sh

az vm create \
  --name "${group}-vm" \
  --resource-group "${group}" \
  --size "Standard_D2s_v3" \
  --os-disk-size-gb "15" \
  --image "${1:-"${img_name}"}" \
  --admin-username "${USER}" \
  --location "westus2" \
  --ssh-key-values "$(ssh-add -L)"
