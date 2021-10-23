#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
thing="${1}"

set -x

nix path-info --derivation -r "${DIR}/..#${thing}" > /tmp/drvs

while read p; do
  if [[ "${p}" != *drv ]]; then continue; fi
  
  nix-build -j0 "${p}"\
    | grep -v fastboot \
    | grep -v partition \
    | grep -v PARTITION \
    | grep -v firmware \
    | grep -v "-bundle" \
    | cachix push "colemickens"
done </tmp/drvs
