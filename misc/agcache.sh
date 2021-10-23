#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
thing="${1}"

nix path-info --derivation -r "${DIR}/..#${thing}" > /tmp/drvs

cat /tmp/drvs | nix-build -j0 \
    | grep -v fastboot \
    | grep -v partition \
    | grep -v PARTITION \
    | cachix push "colemickens"
