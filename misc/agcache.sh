#!/usr/bin/env bash

thing="${1}"

nix path-info --derivation -r "${thing}" > /tmp/drvs
cat /tmp/drvs | nix-build -j0 | cachix push "colemickens"

# grep for dependencies
# push any that are built
# do this continuously I guess?
# come back to niche

