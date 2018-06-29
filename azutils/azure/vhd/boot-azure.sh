#!/usr/bin/env bash
set -x
set -euo pipefail
F="${HOME}/.secretz/azure.sh"; [[ -f "${F}" ]] && source "${F}"

# REQUIRED INPUT
[[ -z "${1:-}" ]] && echo "./${0} <image_name> <deployment_name>" &>2 && exit -1
IMAGE="${1}"
DEPLOYMENT="${2}"
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY}"

# USER OVERRIDEABLE
VM_SIZE="${VM_SIZE:-"Standard_D16s_v3"}"
DISK_SIZE="${DISK_SIZE:-"100"}"
LOCATION="${LOCATION:-"westus2"}"

# remove when we get azure-cli packaged
WORKDIR="$(mktemp -d)"
trap "sudo rm -rf ${WORKDIR}" EXIT
function az() {
    docker run -it -e AZURE_STORAGE_CONNECTION_STRING -v "${WORKDIR}:/root" "docker.io/microsoft/azure-cli:latest" az "$@"
}

# ISOLATE AZURE-CLI ENVIRONMENT (re-enable when we dont rely on docker [which is already isolating the workdi])
#export AZURE_CONFIG_DIR="$(mktemp -d)"
#trap "rm -rf ${AZURE_CONFIG_DIR}" EXIT

# LOGIN
az login --service-principal --username="${AZURE_USERNAME}" --password="${AZURE_PASSWORD}" --tenant="${AZURE_TENANT_ID}"
az account set --subscription="${AZURE_SUBSCRIPTION_ID}"

az group create -n "${DEPLOYMENT}" -l "${LOCATION}"
az vm create \
    --name="${DEPLOYMENT}" \
    --resource-group="${DEPLOYMENT}" \
    --admin-username="${USER}" \
    --size="${VM_SIZE}" \
    --image="${IMAGE}" \
    --os-disk-size-gb="${DISK_SIZE}" \
    --admin-password="Nix0ps123ABC"
    #--ssh-key-value="${SSH_PUBLIC_KEY}"
