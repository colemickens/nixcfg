#!/usr/bin/env bash
set -x
set -euo pipefail
F="${HOME}/.secretz/azure.sh"; [[ -f "${F}" ]] && source "${F}"

# REQUIRED (storage accounts must be globally unique, everything else is unique-per-sub and we're not going to overlap with anything real)
[[ -z "${1:-}" ]] && echo "./${0} <storage_prefix>" &>2 && exit -1
STORAGE_PREFIX="${1}" # in reality this is required

# USER CHOICE
REPLICA="${REPLICA:-"0"}"
LOCATION="${LOCATION:-"westus2"}"

# OPINIONATED, BEST TO LEAVE IT ALONE AND LIVE WITH IT
RG="nixos"
STORAGE="${STORAGE_PREFIX}${REPLICA}${LOCATION}"
CONTAINER="vhds"
STORAGE_TYPE="Premium_LRS"
PARALLELISM=5

# always build
# if we're clean, this is a no-op
# if we're not, we rightfully rebuild
# the hash in the image name is always guaranteed to be good
VHD_DIR="$(./create-azure.sh)"
VHD="${VHD_DIR}/disk.vhd"
UNIQUE="$(echo "${VHD_DIR}" | cut -d '-' -f 1 | cut -d '/' -f 4)"
TARGET="nixos-azure-${UNIQUE}-${LOCATION}.vhd"
IMAGE="nixos-azure-${UNIQUE}-${LOCATION}"

# ISOLATE AZURE-CLI ENVIRONMENT
export AZURE_CONFIG_DIR="$(mktemp -d)"
trap "rm -rf ${AZURE_CONFIG_DIR}" EXIT

# LOGIN
az login --service-principal --username="${AZURE_USERNAME}" --password="${AZURE_PASSWORD}" --tenant="${AZURE_TENANT_ID}"
az account set --subscription="${AZURE_SUBSCRIPTION_ID}"

# RESOURCE GROUP
T="$(az group show -n "${RG}")"
if [[ -z "${T}" ]] ; then
    az group create -n "${RG}" -l "${LOCATION}"
fi

# STORAGE ACCOUNT
if ! az storage account show -n "${STORAGE}" -g "${RG}" &>/dev/null ; then
    az storage account create -n "${STORAGE}" -g "${RG}" --sku "${STORAGE_TYPE}" --kind "StorageV2"
fi
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n "${STORAGE}" -g "${RG}" --query connectionString --output tsv)
export AZURE_STORAGE_KEY="$(az storage account keys list -n "${STORAGE}" -g "${RG}" --query '[0].value' -o tsv)"

# STORAGE CONTAINER
T="$(az storage container show -n "${CONTAINER}")"
if [[ -z "${T}" ]] ; then
    az storage container create -n "${CONTAINER}"
fi

# VHD BLOB UPLOAD
T="$(az storage blob show -c "${CONTAINER}" -n "${TARGET}")"
if [[ -z "${T}" ]] ; then
    az storage blob upload -c "${CONTAINER}" -n "${TARGET}" -f "${VHD}" --max-connections ${PARALLELISM}
fi
BLOBURL="$(az storage blob url -c "${CONTAINER}" -n "${TARGET}" | tr -d '"')"

# IMAGE
IMAGEID=$(az image show -n ${IMAGE} -g ${RG} --query [id] -o tsv)
if [[ -z "${IMAGEID}" ]] ; then
    az image create -n "${IMAGE}" -g "${RG}" --source "${BLOBURL}" --os-type "linux"
    IMAGEID=$(az image show -n ${IMAGE} -g "${RG}" --query [id] -o tsv)
fi

set +x; echo; echo; echo "::::: ${IMAGEID}"; echo;

