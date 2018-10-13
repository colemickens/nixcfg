#!/usr/bin/env bash
set -x
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
nixcfg="${DIR}/.."

nixfiletobuild="${1:-"${nixcfg}/devices/all.nix"}"

results="$(\
  nix-build \
    --option build-cores 0 \
    --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
    --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
    "${nixfiletobuild}")"

echo "${result}" | while read -r closure; do
  ${nixcfg}/utils/nix/ccc.sh "${closure}"
done

${nixcfg}/utils/azure/upload-cache.sh

