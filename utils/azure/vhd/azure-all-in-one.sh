#!/usr/bin/env bash
set -euo pipefail
set -x
F="${HOME}/.secretz/azure.sh"; [[ -f "${F}" ]] && source "${F}"

cd /etc/nixpkgs/nixos/maintainers/scripts/azure/

REPLICA="${REPLICA:-"0"}"
LOCATION="${LOCATION:-"westus2"}"
STORAGE_PREFIX="${STORAGE_PREFIX:-"nixos"}"

echo "==CREATE==" | tee -a "/tmp/azure-all-in-one.log"
VHD_DIR="$(./create-azure.sh | tee -a "/tmp/azure-all-in-one.log")"
UNIQUE="$(echo "${VHD_DIR}" | cut -d '-' -f 1 | cut -d '/' -f 4)"

echo "==UPLOAD==" | tee -a "/tmp/azure-all-in-one.log"
./upload-azure.sh "${STORAGE_PREFIX}" | tee -a "/tmp/azure-all-in-one.log"

echo "==BOOT==" | tee -a "/tmp/azure-all-in-one.log"
IMAGE="/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/nixos/providers/Microsoft.Compute/images/nixos-azure-${UNIQUE}-${LOCATION}"
./boot-azure.sh "${IMAGE}" "auto-nixos-${UNIQUE}-${LOCATION}" | tee -a "/tmp/azure-all-in-one.log"
