#!/usr/bin/env bash

set -x
set -euo pipefail

key="/etc/nixos/secrets/nix-cache.cluster.lol-1-secret"
azkey="$(cat /etc/nixos/secrets/kixstorage-secret)"

# build cache

mkdir -p "/tmp/nixcache"
nix copy --to 'file:///tmp/nixcache' '/run/current-system'
nix sign-paths \
  --store 'file:///tmp/nixcache' -k "${key}" '/run/current-system' -r

# upload

function az() {
  docker run \
    --net=host \
    --env AZURE_STORAGE_CONNECTION_STRING="${azkey}" \
    --volume "/tmp/nixcache:/tmp/nixcache:ro" \
    --volume "/tmp/nixcache-upload:/tmp/nixcache-upload:ro" \
      docker.io/microsoft/azure-cli az $@
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

rm -rf /tmp/nixcache-upload
mkdir -p /tmp/nixcache-upload
cd /tmp/nixcache
az storage blob list --container-name nixcache -o tsv | cut -f4 > .rgignore
rg -l . | while read -r a; do ln -s /tmp/nixcache/$a /tmp/nixcache-upload/$a; done

time az storage blob upload-batch \
  --source /tmp/nixcache-upload \
  --destination nixcache \

rm -rf /tmp/nixcache-upload

