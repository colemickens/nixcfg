#!/usr/bin/env bash

set -x
set -euo pipefail

target="${1:-"/run/current-system"}"

key="/etc/nixos/secrets/nix-cache.cluster.lol-1-secret"
export AZURE_STORAGE_CONNECTION_STRING="$(cat /etc/nixos/secrets/kixstorage-secret)"

# we reuse the store for everything, persist between boots
# we need root to make it once
store="/var/lib/nixcache"

# build cache
sudo mkdir -p "${store}/nar"
sudo chown -R cole:cole "${store}"
nix copy --to "file://${store}" "${target}"
nix sign-paths --store "file://${store}" -k "${key}" "${target}" -r

# prep staging dir (must do this before docker, else its done as root, I guess)
rm -rf /tmp/nixcache-upload/*
mkdir -p /tmp/nixcache-upload/nar

# upload
function az() {
  command az $@
#  docker run \
#    --net=host \
#    --env AZURE_STORAGE_CONNECTION_STRING \
#    --volume "/tmp/nixcache:/tmp/nixcache:ro" \
#    --volume "/tmp/nixcache-upload:/tmp/nixcache-upload:ro" \
#      docker.io/microsoft/azure-cli az $@
}

if ! az storage container show --name nixcache ; then
  az storage container create --help

  az storage container create \
    --name nixcache \
    --public-access container
fi

# Find only the new files to upload
bloblist="$(mktemp)"
blobnames="$(mktemp)"
az storage blob list --container-name nixcache | jq -r '.' > "${bloblist}"
cat "${bloblist}" | jq -r '.[].name' > "${blobnames}"

uploaddir="$(mktemp -d)"

cd /tmp/nixcache
find . ! -path . -type f | grep -vFf "${blobnames}" | while read -r pth; do
  ln -s "${store}/${pth}" "${uploaddir}/${pth}"
done

exit 0

time az storage blob upload-batch \
  --source /tmp/nixcache-upload \
  --destination nixcache \

# rm -rf /tmp/nixcache-upload

