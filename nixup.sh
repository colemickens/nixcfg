#!/usr/bin/env bash

unset NIX_PATH
unset NIXOS_CONFIG

# prove we can do day-to-day nixos operations without:
# NIX_PATH, NIXOS_CONFIG, nor `nixos-*` commands

system="$(nix-build -A xeepSystem default.nix)"

"${system}/switch-to-configuration" switch
