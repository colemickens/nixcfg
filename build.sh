#!/usr/bin/env bash

nixcfg="/etc/nixcfg"

unset NIX_PATH
unset NIXOS_CONFIG

"${nixcfg}/utils/azure/nix-build.sh" "$(pwd)/default.nix"

