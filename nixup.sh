#!/usr/bin/env bash

unset NIX_PATH
unset NIXOS_CONFIG

# prove we can do day-to-day nixos operations without:
# NIX_PATH, NIXOS_CONFIG, nor `nixos-*` commands

target="$(hostname)System"
system="$(nix-build -A "${target}" default.nix)"

sudo "${system}/bin/switch-to-configuration" switch

