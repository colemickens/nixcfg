#!/usr/bin/env bash

set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

target="$(hostname)__local"
toplevel=$(./nixbuild.sh default.nix -A "${target}.machine.config.system.build.toplevel")

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${toplevel}"

sudo "${toplevel}/bin/switch-to-configuration" switch
