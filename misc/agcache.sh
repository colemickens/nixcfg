#!/usr/bin/env bash

thing="${1}"

nix path-info --derivation -r "${thing}" > /tmp/drvs

cat /tmp/drvs | nix-build -j0 \
    | grep -v fastboot \
    | grep -v partition \
    | grep -v PARTITION \
    | cachix push "colemickens"
