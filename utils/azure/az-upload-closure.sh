#!/usr/bin/env bash

set -x
set -euo pipefail

target="${1:-"/run/current-system"}"
container="nixcache"

key="/etc/nixos/secrets/nix-cache.cluster.lol-1-secret"
export AZURE_STORAGE_CONNECTION_STRING="$(cat /etc/nixos/secrets/kixstorage-secret)"

# prep our store
store="/var/lib/nixcache"
sudo mkdir -p "${store}/nar"
sudo chown -R cole:cole "${store}"

# prep upload dir
uploaddir="$(mktemp -d)"
mkdir -p "${uploaddir}/nar"

# build cache
nix copy --to "file://${store}" "${target}"
nix sign-paths --store "file://${store}" -k "${key}" "${target}" -r

# upload
if ! az storage container show --name "${container}" ; then
  az storage container create --name "${container}" --public-access container
fi

# Find only the new files to upload
bloblist="$(mktemp)"
blobnames="$(mktemp)"
az storage blob list --container-name "${container}" | jq -r '.' > "${bloblist}"
cat "${bloblist}" | jq -r '.[].name' > "${blobnames}"

cd "${store}"
find . ! -path . -type f -printf '%P\n'| grep -vFf "${blobnames}" | while read -r pth; do
  ln -s "${store}/${pth}" "${uploaddir}/${pth}"
done

time az storage blob upload-batch \
  --source "${uploaddir}" \
  --destination nixcache \

