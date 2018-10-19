#!/usr/bin/env bash
set -x
set -euo pipefail

##
## 1. get a list of all files in the azure cache container already; persist to ${blobnames}
## 2. create a symlnk in ${uploadddir} for each file in ${store} that is not also in ${blobnames}
## 3. leverage "az storage blob upload-batch" to quickly upload what doesn't exist
##
## NOTE: this is not going to handle key rotation well (which is unfortunately not evident here)
## When the signing key is rotated, narinfos that are already in azure are not going to be updated
##
## TODO: we could have a mode where we purge all narinfos first...
## 

export AZURE_STORAGE_CONNECTION_STRING="$(cat /etc/nixos/secrets/kixstorage-secret)"

container="${AZURE_STORAGE_CONTAINER:-"nixcache"}"
store="${1:-"${HOME}/.nixcache"}"

# prep upload dir
uploaddir="$(mktemp -d)"
mkdir -p "${uploaddir}/nar"

# upload
# BUG: ref:
#if ! az storage container show --name "${container}" ; then
cc="$(az storage container list -o json)"
cc="$(echo "${cc}" | jq -r "[ .[] | select(.name==\"${container}\") ] | length")"
if [[ "${cc}" == 0 ]]; then
  az storage container create --name "${container}" --public-access container
fi

# Find only the new files to upload
bloblist="$(mktemp)"
blobnames="$(mktemp)"
blobsizes="$(mktemp)"
function blobdata() {
  az storage blob list --container-name "${container}" | jq -r '.' > "${bloblist}"
  cat "${bloblist}" | jq -r '.[].name' > "${blobnames}"
  cat "${bloblist}" | jq -r '.[].properties.contentLength' > "${blobsizes}"
  totalblobsize="$(awk '{ sum += $1 } END { print sum }' "${blobsizes}")"
}

cd "${store}"
find . ! -path . -type f -printf '%P\n'| grep -vFf "${blobnames}" | while read -r pth; do
  ln -s "${store}/${pth}" "${uploaddir}/${pth}"
  if [[ "${pth}" == "*narinfo" ]]; then cat "${store}/${pth}" | grep StorePath; fi
done

time az storage blob upload-batch \
  --source "${uploaddir}" \
  --destination "${container}" \

blobdata # update our blob metadata so we can report usage
echo "==> ${container} disk usage = ${totalblobsize}"

