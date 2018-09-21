#!/usr/bin/env bash

set -x
set -euo pipefail

target="${1:-"/run/current-system"}"

key="/etc/nixos/secrets/nix-cache.cluster.lol-1-secret"
export AZURE_STORAGE_CONNECTION_STRING="$(cat /etc/nixos/secrets/kixstorage-secret)"

# build cache
#mkdir -p "/tmp/nixcache/nar"
#nix copy --to 'file:///tmp/nixcache' "${target}"
#nix sign-paths --store 'file:///tmp/nixcache' -k "${key}" "${target}" -r

# upload

function az() {
  command az $@
  #docker run \
  #  --net=host \
  #  --env AZURE_STORAGE_CONNECTION_STRING \
  #  --volume "/tmp/nixcache:/tmp/nixcache:ro" \
  #  --volume "/tmp/nixcache-upload:/tmp/nixcache-upload:ro" \
  #    docker.io/microsoft/azure-cli az $@
}

# only to clean?
#if az storage container show --name nixcache; then
#  az storage container delete --name nixcache
#  sleep 60
#fi

if ! az storage container show --name nixcache ; then
  az storage container create --help

  az storage container create \
    --name nixcache \
    --public-access container
fi

# Find only the new files to upload
rm -rf /tmp/nixcache-upload
mkdir -p /tmp/nixcache-upload/nar
cd /tmp/nixcache
az storage blob list --container-name nixcache | jq -r '.[].name' > /tmp/nixcache-skip
find . ! -path . -type f | grep -vFf /tmp/nixcache-skip | while read -r a; do
  ln -s /tmp/nixcache/$a /tmp/nixcache-upload/$a
done

time az storage blob upload-batch \
  --source /tmp/nixcache-upload \
  --destination nixcache \

rm -rf /tmp/nixcache-upload

